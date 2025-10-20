require "json"
require "base64"
require "openssl/hmac"

module Orion::Middleware
  # Session management middleware for Orion
  # Supports multiple storage backends (Cookie, Memory, Redis)
  #
  # Usage:
  #   use Orion::Middleware::Session.new(
  #     secret: ENV["SECRET_KEY_BASE"],
  #     store: :cookie,  # or :memory, :redis
  #     expire_after: 2.hours
  #   )
  #
  # In routes:
  #   session[:user_id] = 123
  #   session[:user_id]?  # => 123
  #   session.delete(:user_id)
  class Session
    include HTTP::Handler

    property secret : String
    property cookie_name : String
    property expire_after : Time::Span
    property store : Store

    def initialize(
      @secret : String,
      @cookie_name : String = "_orion_session",
      @expire_after : Time::Span = 2.hours,
      store : Symbol | Store = :cookie,
      @same_site : HTTP::Cookie::SameSite = HTTP::Cookie::SameSite::Lax,
      @secure : Bool = false,
      @http_only : Bool = true
    )
      @store = case store
               when :cookie then CookieStore.new(@secret)
               when :memory then MemoryStore.new
               else
                 store.as(Store)
               end
    end

    def call(context : HTTP::Server::Context)
      # Load session from request
      session_id = load_session_id(context.request)
      session_data = @store.load(session_id)

      # Attach session to context
      context.as(Orion::Server::Context).session = SessionStore.new(session_data, session_id)

      call_next(context)

      # Save session to response
      orion_context = context.as(Orion::Server::Context)
      if orion_context.session.modified?
        new_session_id = @store.save(orion_context.session.id, orion_context.session.data)
        save_session_cookie(context.response, new_session_id)
      end
    end

    private def load_session_id(request : HTTP::Request) : String?
      request.cookies[@cookie_name]?.try(&.value)
    end

    private def save_session_cookie(response : HTTP::Server::Response, session_id : String)
      cookie = HTTP::Cookie.new(
        name: @cookie_name,
        value: session_id,
        path: "/",
        expires: Time.utc + @expire_after,
        secure: @secure,
        http_only: @http_only,
        same_site: @same_site
      )
      response.cookies << cookie
    end
  end

  # Session storage interface
  abstract class Store
    abstract def load(session_id : String?) : Hash(String, String)
    abstract def save(session_id : String?, data : Hash(String, String)) : String
    abstract def delete(session_id : String) : Nil
  end

  # Cookie-based session store (signed and optionally encrypted)
  class CookieStore < Store
    def initialize(@secret : String)
    end

    def load(session_id : String?) : Hash(String, String)
      return {} of String => String unless session_id

      # Verify signature and decode
      return {} of String => String unless valid_signature?(session_id)

      payload = session_id.split("--").first
      decoded = Base64.decode_string(payload)
      Hash(String, String).from_json(decoded)
    rescue
      {} of String => String
    end

    def save(session_id : String?, data : Hash(String, String)) : String
      payload = Base64.strict_encode(data.to_json)
      signature = generate_signature(payload)
      "#{payload}--#{signature}"
    end

    def delete(session_id : String) : Nil
      # Cookie store doesn't need server-side deletion
    end

    private def valid_signature?(signed_value : String) : Bool
      parts = signed_value.split("--")
      return false if parts.size != 2

      payload, signature = parts
      expected_signature = generate_signature(payload)

      # Constant-time comparison
      OpenSSL::HMAC.hexdigest(:sha256, @secret, signature) ==
        OpenSSL::HMAC.hexdigest(:sha256, @secret, expected_signature)
    end

    private def generate_signature(payload : String) : String
      OpenSSL::HMAC.hexdigest(:sha256, @secret, payload)
    end
  end

  # Memory-based session store (for development/testing)
  class MemoryStore < Store
    @@sessions = {} of String => Hash(String, String)

    def load(session_id : String?) : Hash(String, String)
      return {} of String => String unless session_id
      @@sessions[session_id]? || {} of String => String
    end

    def save(session_id : String?, data : Hash(String, String)) : String
      id = session_id || generate_session_id
      @@sessions[id] = data
      id
    end

    def delete(session_id : String) : Nil
      @@sessions.delete(session_id)
    end

    private def generate_session_id : String
      Random::Secure.hex(32)
    end
  end

  # Session data container
  class SessionStore
    getter data : Hash(String, String)
    getter id : String?
    getter? modified : Bool = false

    def initialize(@data = {} of String => String, @id : String? = nil)
    end

    def []=(key : String | Symbol, value)
      @data[key.to_s] = value.to_s
      @modified = true
      value
    end

    def [](key : String | Symbol) : String
      @data[key.to_s]
    end

    def []?(key : String | Symbol) : String?
      @data[key.to_s]?
    end

    def delete(key : String | Symbol) : String?
      @modified = true
      @data.delete(key.to_s)
    end

    def clear
      @modified = true
      @data.clear
    end

    def has_key?(key : String | Symbol) : Bool
      @data.has_key?(key.to_s)
    end
  end

  # Flash messages (temporary session data for next request)
  class Flash
    def initialize(@session : SessionStore)
      load_flash
    end

    def []=(key : String | Symbol, value : String)
      next_flash[key.to_s] = value
    end

    def [](key : String | Symbol) : String?
      current_flash[key.to_s]?
    end

    def []?(key : String | Symbol) : String?
      current_flash[key.to_s]?
    end

    def now
      current_flash
    end

    private def current_flash : Hash(String, String)
      @current_flash ||= begin
        if data = @session["_flash"]?
          Hash(String, String).from_json(data)
        else
          {} of String => String
        end
      end
    end

    private def next_flash : Hash(String, String)
      @next_flash ||= {} of String => String
    end

    private def load_flash
      # Current flash is loaded lazily
    end

    def persist!
      if @next_flash
        @session["_flash"] = @next_flash.not_nil!.to_json
      else
        @session.delete("_flash")
      end
    end
  end
end

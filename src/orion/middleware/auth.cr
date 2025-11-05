require "json"
require "base64"
require "openssl/hmac"

module Orion::Middleware
  # Base authentication handler
  # Extend this to create custom authentication strategies
  abstract class Auth
    include HTTP::Handler

    # Override this to implement authentication logic
    abstract def authenticate(context : Orion::Server::Context) : Bool

    # Override to customize unauthorized response
    def unauthorized_response(context : Orion::Server::Context)
      context.response.status_code = 401
      context.response.content_type = "application/json"
      context.response.print({error: "Unauthorized"}.to_json)
    end

    def call(context : HTTP::Server::Context)
      # Orion middleware expects Orion::Server::Context
      orion_context = context
      return call_next(context) unless orion_context.is_a?(Orion::Server::Context)

      if authenticate(orion_context)
        call_next(context)
      else
        unauthorized_response(orion_context)
      end
    end
  end

  # Session-based authentication
  # Checks for user_id in session
  #
  # Usage:
  #   use Orion::Middleware::SessionAuth.new(
  #     session_key: :user_id,
  #     redirect_to: "/login"  # optional redirect instead of 401
  #   )
  class SessionAuth < Auth
    property session_key : String | Symbol
    property redirect_to : String?

    def initialize(
      @session_key : String | Symbol = :user_id,
      @redirect_to : String? = nil,
    )
    end

    def authenticate(context : Orion::Server::Context) : Bool
      context.session[@session_key]? != nil
    end

    def unauthorized_response(context : Orion::Server::Context)
      if redirect = @redirect_to
        context.response.status_code = 302
        context.response.headers["Location"] = redirect
      else
        super
      end
    end

    # Helper to get authenticated user ID
    def self.user_id(context : Orion::Server::Context, key : String | Symbol = :user_id) : String?
      context.session[key]?
    end

    # Helper to set authenticated user
    def self.login(context : Orion::Server::Context, user_id : String | Int, key : String | Symbol = :user_id)
      context.session[key] = user_id.to_s
    end

    # Helper to logout
    def self.logout(context : Orion::Server::Context, key : String | Symbol = :user_id)
      context.session.delete(key)
    end
  end

  # JWT Token authentication
  # Validates Bearer tokens in Authorization header
  #
  # Usage:
  #   use Orion::Middleware::JWTAuth.new(
  #     secret: ENV["JWT_SECRET"],
  #     algorithm: :HS256
  #   )
  class JWTAuth < Auth
    property secret : String
    property algorithm : Symbol
    property header_name : String

    def initialize(
      @secret : String,
      @algorithm : Symbol = :HS256,
      @header_name : String = "Authorization",
    )
    end

    def authenticate(context : Orion::Server::Context) : Bool
      auth_header = context.request.headers[@header_name]?
      return false unless auth_header

      # Extract Bearer token
      return false unless auth_header.starts_with?("Bearer ")
      token = auth_header[7..]

      # Verify and decode token
      if payload = verify_token(token)
        # Attach payload to context for later use
        context.request.as(Orion::Server::Request).jwt_payload = payload
        true
      else
        false
      end
    rescue
      false
    end

    private def verify_token(token : String) : Hash(String, JSON::Any)?
      parts = token.split(".")
      return nil unless parts.size == 3

      header_encoded, payload_encoded, signature_encoded = parts

      # Verify signature
      message = "#{header_encoded}.#{payload_encoded}"
      expected_signature = generate_signature(message)

      return nil unless secure_compare(
                          Base64.decode(signature_encoded),
                          expected_signature
                        )

      # Decode payload
      payload_json = Base64.decode_string(payload_encoded)
      payload = Hash(String, JSON::Any).from_json(payload_json)

      # Check expiration
      if exp = payload["exp"]?
        exp_time = Time.unix(exp.as_i64)
        return nil if Time.utc > exp_time
      end

      payload
    rescue
      nil
    end

    private def generate_signature(message : String) : Bytes
      case @algorithm
      when :HS256
        OpenSSL::HMAC.digest(:sha256, @secret, message)
      when :HS512
        OpenSSL::HMAC.digest(:sha512, @secret, message)
      else
        raise "Unsupported algorithm: #{@algorithm}"
      end
    end

    private def secure_compare(a : Bytes, b : Bytes) : Bool
      return false unless a.size == b.size

      result = 0
      a.each_with_index do |byte, i|
        result |= (byte ^ b[i])
      end
      result == 0
    end

    # Helper to generate JWT tokens
    def self.generate_token(
      payload : Hash(String, JSON::Any),
      secret : String,
      algorithm : Symbol = :HS256,
      expires_in : Time::Span = 24.hours,
    ) : String
      # Add expiration
      payload["exp"] = JSON::Any.new((Time.utc + expires_in).to_unix)
      payload["iat"] = JSON::Any.new(Time.utc.to_unix)

      # Create header
      header = {
        "typ" => "JWT",
        "alg" => algorithm.to_s,
      }

      # Encode header and payload
      header_encoded = Base64.strict_encode(header.to_json)
      payload_encoded = Base64.strict_encode(payload.to_json)

      # Generate signature
      message = "#{header_encoded}.#{payload_encoded}"
      signature = case algorithm
                  when :HS256
                    OpenSSL::HMAC.digest(:sha256, secret, message)
                  when :HS512
                    OpenSSL::HMAC.digest(:sha512, secret, message)
                  else
                    raise "Unsupported algorithm: #{algorithm}"
                  end

      signature_encoded = Base64.strict_encode(signature)

      "#{header_encoded}.#{payload_encoded}.#{signature_encoded}"
    end
  end

  # API Key authentication
  # Validates API keys in custom header or query parameter
  #
  # Usage:
  #   use Orion::Middleware::APIKeyAuth.new(
  #     keys: ["key1", "key2"],
  #     header_name: "X-API-Key"
  #   )
  class APIKeyAuth < Auth
    property keys : Array(String)
    property header_name : String
    property query_param : String?

    def initialize(
      @keys : Array(String),
      @header_name : String = "X-API-Key",
      @query_param : String? = "api_key",
    )
    end

    def authenticate(context : Orion::Server::Context) : Bool
      # Try header first
      if api_key = context.request.headers[@header_name]?
        return @keys.includes?(api_key)
      end

      # Try query parameter
      if param = @query_param
        if api_key = context.request.query_params[param]?
          return @keys.includes?(api_key)
        end
      end

      false
    end
  end

  # Basic HTTP Authentication
  # Validates username/password via Basic auth
  #
  # Usage:
  #   use Orion::Middleware::BasicAuth.new(
  #     realm: "Admin Area",
  #     credentials: {"admin" => "password123"}
  #   )
  class BasicAuth < Auth
    property realm : String
    property credentials : Hash(String, String)

    def initialize(
      @realm : String = "Restricted Area",
      @credentials : Hash(String, String) = {} of String => String,
    )
    end

    def authenticate(context : Orion::Server::Context) : Bool
      auth_header = context.request.headers["Authorization"]?
      return false unless auth_header

      return false unless auth_header.starts_with?("Basic ")
      encoded = auth_header[6..]

      decoded = Base64.decode_string(encoded)
      username, password = decoded.split(":", 2)

      @credentials[username]? == password
    rescue
      false
    end

    def unauthorized_response(context : Orion::Server::Context)
      context.response.status_code = 401
      context.response.headers["WWW-Authenticate"] = %(Basic realm="#{@realm}")
      context.response.print "Unauthorized"
    end
  end
end

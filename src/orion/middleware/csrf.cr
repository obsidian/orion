require "base64"
require "openssl/hmac"

module Orion::Middleware
  # CSRF (Cross-Site Request Forgery) Protection
  # Generates and validates CSRF tokens for state-changing requests
  #
  # Usage:
  #   use Orion::Middleware::CSRF.new(secret: ENV["SECRET_KEY_BASE"])
  #
  # In views:
  #   <%= csrf_token %>           # Get token
  #   <%= csrf_meta_tags %>       # Add meta tags
  #   <%= csrf_hidden_field %>    # Add hidden form field
  class CSRF
    include HTTP::Handler

    SAFE_METHODS = %w(GET HEAD OPTIONS TRACE)
    TOKEN_LENGTH = 32

    property secret : String
    property header_name : String
    property param_name : String
    property cookie_name : String

    def initialize(
      @secret : String,
      @header_name : String = "X-CSRF-Token",
      @param_name : String = "csrf_token",
      @cookie_name : String = "_csrf_token",
    )
    end

    def call(context : HTTP::Server::Context)
      # Orion middleware expects Orion::Server::Context
      orion_context = context
      return call_next(context) unless orion_context.is_a?(Orion::Server::Context)

      # Generate token for this request
      token = generate_token
      orion_context.csrf_token = token

      # Skip validation for safe methods
      if SAFE_METHODS.includes?(context.request.method)
        set_token_cookie(context.response, token)
        call_next(context)
        return
      end

      # Validate token for unsafe methods
      if valid_token?(context.request)
        set_token_cookie(context.response, token)
        call_next(context)
      else
        context.response.status_code = 403
        context.response.content_type = "application/json"
        context.response.print({error: "Invalid CSRF token"}.to_json)
      end
    end

    private def valid_token?(request : HTTP::Request) : Bool
      # Try to get token from header
      submitted_token = request.headers[@header_name]?

      # Try to get token from form parameter
      submitted_token ||= request.query_params[@param_name]?

      # Try to get token from request body (if form data)
      if !submitted_token && request.headers["Content-Type"]?.try(&.starts_with?("application/x-www-form-urlencoded"))
        # This is a simplified check - in production you'd parse the body
        # For now, we'll rely on header or query param
      end

      return false unless submitted_token

      # Compare with cookie token
      cookie_token = request.cookies[@cookie_name]?.try(&.value)
      return false unless cookie_token

      # Constant-time comparison
      secure_compare(submitted_token, cookie_token)
    end

    private def generate_token : String
      Random::Secure.hex(TOKEN_LENGTH)
    end

    private def set_token_cookie(response : HTTP::Server::Response, token : String)
      cookie = HTTP::Cookie.new(
        name: @cookie_name,
        value: token,
        path: "/",
        http_only: false, # JavaScript needs to read this
        samesite: HTTP::Cookie::SameSite::Strict
      )
      response.cookies << cookie
    end

    private def secure_compare(a : String, b : String) : Bool
      return false unless a.bytesize == b.bytesize

      result = 0
      a.each_byte.zip(b.each_byte) do |x, y|
        result |= (x ^ y)
      end
      result == 0
    end
  end
end

module Orion::Middleware
  # CORS (Cross-Origin Resource Sharing) middleware
  # Handles preflight requests and sets CORS headers
  #
  # Usage:
  #   use Orion::Middleware::CORS.new(
  #     origins: ["https://example.com", "https://app.example.com"],
  #     methods: ["GET", "POST", "PUT", "DELETE"],
  #     headers: ["Content-Type", "Authorization"],
  #     credentials: true,
  #     max_age: 3600
  #   )
  #
  # Or allow all (development only):
  #   use Orion::Middleware::CORS.new(allow_all: true)
  class CORS
    include HTTP::Handler

    property origins : Array(String) | String
    property methods : Array(String)
    property headers : Array(String)
    property exposed_headers : Array(String)
    property credentials : Bool
    property max_age : Int32

    def initialize(
      @origins : Array(String) | String = [] of String,
      @methods : Array(String) = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      @headers : Array(String) = ["Content-Type", "Authorization"],
      @exposed_headers : Array(String) = [] of String,
      @credentials : Bool = false,
      @max_age : Int32 = 3600,
      allow_all : Bool = false
    )
      if allow_all
        @origins = "*"
        @credentials = false  # Can't use credentials with *
      end
    end

    def call(context : HTTP::Server::Context)
      request_origin = context.request.headers["Origin"]?

      # Skip CORS if no Origin header (same-origin request)
      unless request_origin
        call_next(context)
        return
      end

      # Check if origin is allowed
      unless origin_allowed?(request_origin)
        call_next(context)
        return
      end

      # Handle preflight request
      if context.request.method == "OPTIONS"
        handle_preflight(context, request_origin)
        return
      end

      # Add CORS headers to actual request
      add_cors_headers(context.response, request_origin)
      call_next(context)
    end

    private def origin_allowed?(origin : String) : Bool
      case @origins
      when "*"
        true
      when String
        @origins == origin
      when Array
        @origins.includes?(origin)
      else
        false
      end
    end

    private def handle_preflight(context : HTTP::Server::Context, origin : String)
      response = context.response

      # Set status
      response.status_code = 204

      # Add CORS headers
      add_cors_headers(response, origin)

      # Add preflight-specific headers
      response.headers["Access-Control-Allow-Methods"] = @methods.join(", ")
      response.headers["Access-Control-Allow-Headers"] = @headers.join(", ")
      response.headers["Access-Control-Max-Age"] = @max_age.to_s
    end

    private def add_cors_headers(response : HTTP::Server::Response, origin : String)
      # Set origin
      if @origins == "*"
        response.headers["Access-Control-Allow-Origin"] = "*"
      else
        response.headers["Access-Control-Allow-Origin"] = origin
        response.headers["Vary"] = "Origin"  # Cache should vary by origin
      end

      # Set credentials
      if @credentials
        response.headers["Access-Control-Allow-Credentials"] = "true"
      end

      # Set exposed headers
      unless @exposed_headers.empty?
        response.headers["Access-Control-Expose-Headers"] = @exposed_headers.join(", ")
      end
    end
  end
end

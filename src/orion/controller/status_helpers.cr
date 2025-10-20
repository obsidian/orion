module Orion::Controller
  # HTTP Status Code Helpers
  # Provides semantic methods for setting HTTP status codes
  #
  # Usage:
  #   get "/not-found" do
  #     not_found!
  #   end
  #
  #   get "/api/user" do
  #     unauthorized! json: {error: "Invalid token"}
  #   end
  module StatusHelpers
    # 2xx Success
    def ok!(message : String? = nil)
      response.status_code = 200
      render text: message if message
    end

    def created!(message : String? = nil, *, json = nil, location : String? = nil)
      response.status_code = 201
      response.headers["Location"] = location if location

      if json
        render json: json
      elsif message
        render text: message
      end
    end

    def accepted!(message : String? = nil)
      response.status_code = 202
      render text: message if message
    end

    def no_content!
      response.status_code = 204
      # No content body
    end

    # 3xx Redirection
    def moved_permanently!(location : String)
      response.status_code = 301
      response.headers["Location"] = location
    end

    def found!(location : String)
      response.status_code = 302
      response.headers["Location"] = location
    end

    def see_other!(location : String)
      response.status_code = 303
      response.headers["Location"] = location
    end

    def not_modified!
      response.status_code = 304
    end

    def temporary_redirect!(location : String)
      response.status_code = 307
      response.headers["Location"] = location
    end

    def permanent_redirect!(location : String)
      response.status_code = 308
      response.headers["Location"] = location
    end

    # 4xx Client Errors
    def bad_request!(message : String = "Bad Request", *, json = nil)
      response.status_code = 400
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def unauthorized!(message : String = "Unauthorized", *, json = nil, www_authenticate : String? = nil)
      response.status_code = 401
      response.headers["WWW-Authenticate"] = www_authenticate if www_authenticate

      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def payment_required!(message : String = "Payment Required")
      response.status_code = 402
      response.print message
    end

    def forbidden!(message : String = "Forbidden", *, json = nil)
      response.status_code = 403
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def not_found!(message : String = "Not Found", *, json = nil)
      response.status_code = 404
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def method_not_allowed!(message : String = "Method Not Allowed", allowed_methods : Array(String)? = nil)
      response.status_code = 405
      response.headers["Allow"] = allowed_methods.join(", ") if allowed_methods
      response.print message
    end

    def not_acceptable!(message : String = "Not Acceptable")
      response.status_code = 406
      response.print message
    end

    def conflict!(message : String = "Conflict", *, json = nil)
      response.status_code = 409
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def gone!(message : String = "Gone")
      response.status_code = 410
      response.print message
    end

    def unprocessable_entity!(message : String = "Unprocessable Entity", *, json = nil)
      response.status_code = 422
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def too_many_requests!(message : String = "Too Many Requests", retry_after : Int32? = nil)
      response.status_code = 429
      response.headers["Retry-After"] = retry_after.to_s if retry_after
      response.print message
    end

    # 5xx Server Errors
    def internal_server_error!(message : String = "Internal Server Error", *, json = nil)
      response.status_code = 500
      if json
        response.content_type = "application/json"
        response.print json.to_json
      else
        response.print message
      end
    end

    def not_implemented!(message : String = "Not Implemented")
      response.status_code = 501
      response.print message
    end

    def bad_gateway!(message : String = "Bad Gateway")
      response.status_code = 502
      response.print message
    end

    def service_unavailable!(message : String = "Service Unavailable", retry_after : Int32? = nil)
      response.status_code = 503
      response.headers["Retry-After"] = retry_after.to_s if retry_after
      response.print message
    end

    def gateway_timeout!(message : String = "Gateway Timeout")
      response.status_code = 504
      response.print message
    end

    # Generic status setter
    def status(code : Int32)
      response.status_code = code
    end

    # Head response (status only, no body)
    def head(status : Int32 | Symbol)
      response.status_code = case status
                             when :ok then 200
                             when :created then 201
                             when :accepted then 202
                             when :no_content then 204
                             when :moved_permanently then 301
                             when :found then 302
                             when :not_modified then 304
                             when :bad_request then 400
                             when :unauthorized then 401
                             when :forbidden then 403
                             when :not_found then 404
                             when :unprocessable_entity then 422
                             when :internal_server_error then 500
                             else
                               status.as(Int32)
                             end
    end
  end
end

# Context Helpers - Convenience methods on Server::Context
# Makes all helpers easily discoverable via context parameter
#
# Usage:
#   get "/users/:id" do |ctx|
#     user = User.find?(ctx.params["id"])
#     ctx.not_found! unless user
#     ctx.json(user.to_h)
#   end
class Orion::Server::Context
  # ===== PARAMETER ACCESS =====

  # Unified parameter access (path_params + query_params)
  # Shorthand for accessing params without going through request
  def params : ParamHash
    @_params ||= ParamHash.new(self)
  end

  # Shorthand for path parameters
  def path_params : Hash(String, String)
    request.path_params
  end

  # Shorthand for query parameters
  def query_params : HTTP::Params
    request.query_params
  end

  # ===== JSON RESPONSES =====

  # Render JSON response
  def json(data, status : Int32 = 200)
    response.status_code = status
    response.content_type = "application/json"
    response.print data.to_json
  end

  # JSON with specific statuses
  def json_ok(data)
    json(data, 200)
  end

  def json_created(data)
    json(data, 201)
  end

  def json_accepted(data)
    json(data, 202)
  end

  def json_bad_request(data)
    json(data, 400)
  end

  def json_unauthorized(data)
    json(data, 401)
  end

  def json_forbidden(data)
    json(data, 403)
  end

  def json_not_found(data)
    json(data, 404)
  end

  def json_unprocessable(data)
    json(data, 422)
  end

  def json_server_error(data)
    json(data, 500)
  end

  # ===== STATUS HELPERS =====

  # 2xx Success
  def ok!(message : String? = nil)
    response.status_code = 200
    response.print message if message
  end

  def created!(message = nil, json = nil, location : String? = nil)
    response.status_code = 201
    response.headers["Location"] = location if location

    if json
      self.json(json, 201)
    elsif message
      response.print message.to_s
    end
  end

  def no_content!
    response.status_code = 204
  end

  # 3xx Redirects
  def redirect!(location : String, status : Int32 = 302)
    response.status_code = status
    response.headers["Location"] = location
  end

  def moved!(location : String)
    redirect!(location, 301)
  end

  def found!(location : String)
    redirect!(location, 302)
  end

  # 4xx Client Errors
  def bad_request!(message = "Bad Request", json = nil)
    response.status_code = 400
    json ? self.json(json, 400) : response.print(message.to_s)
  end

  def unauthorized!(message = "Unauthorized", json = nil)
    response.status_code = 401
    json ? self.json(json, 401) : response.print(message.to_s)
  end

  def forbidden!(message = "Forbidden", json = nil)
    response.status_code = 403
    json ? self.json(json, 403) : response.print(message.to_s)
  end

  def not_found!(message = "Not Found", json = nil)
    response.status_code = 404
    json ? self.json(json, 404) : response.print(message.to_s)
  end

  def conflict!(message = "Conflict", json = nil)
    response.status_code = 409
    json ? self.json(json, 409) : response.print(message.to_s)
  end

  def unprocessable!(message = "Unprocessable Entity", json = nil)
    response.status_code = 422
    json ? self.json(json, 422) : response.print(message.to_s)
  end

  def too_many_requests!(message = "Too Many Requests", retry_after : Int32? = nil)
    response.status_code = 429
    response.headers["Retry-After"] = retry_after.to_s if retry_after
    response.print message.to_s
  end

  # 5xx Server Errors
  def server_error!(message = "Internal Server Error", json = nil)
    response.status_code = 500
    json ? self.json(json, 500) : response.print(message.to_s)
  end

  def service_unavailable!(message = "Service Unavailable", retry_after : Int32? = nil)
    response.status_code = 503
    response.headers["Retry-After"] = retry_after.to_s if retry_after
    response.print message.to_s
  end

  # Generic status
  def status(code : Int32)
    response.status_code = code
  end

  def head(status : Int32 | Symbol)
    response.status_code = case status
                           when :ok           then 200
                           when :created      then 201
                           when :no_content   then 204
                           when :not_found    then 404
                           when :unauthorized then 401
                           when :forbidden    then 403
                           when :server_error then 500
                           else                    status.as(Int32)
                           end
  end

  # ===== RENDERING =====

  # Render text response
  def render_text(text : String, status : Int32 = 200)
    response.status_code = status
    response.content_type = "text/plain"
    response.print text
  end

  # Render HTML response
  def render_html(html : String, status : Int32 = 200)
    response.status_code = status
    response.content_type = "text/html"
    response.print html
  end

  # ===== HELPERS =====

  # Halt processing
  def halt(status : Int32, message : String? = nil)
    response.status_code = status
    response.print message if message
    # This doesn't actually halt in current implementation
    # but sets the status for middleware to handle
  end

  # Parameter helper class
  class ParamHash
    def initialize(@context : Context)
    end

    def [](key : String | Symbol) : String
      self[key]? || raise ParametersMissing.new("Missing parameter: #{key}")
    end

    def []?(key : String | Symbol) : String?
      key_str = key.to_s

      # Path params first (highest priority)
      if value = @context.request.path_params[key_str]?
        return value
      end

      # Query params second
      if value = @context.request.query_params[key_str]?
        return value
      end

      nil
    end

    def has_key?(key : String | Symbol) : Bool
      !!self[key]?
    end

    def keys : Array(String)
      (@context.request.path_params.keys +
        @context.request.query_params.keys).uniq
    end

    def to_h : Hash(String, String)
      result = {} of String => String
      keys.each { |key| result[key] = self[key] }
      result
    end

    # Strong parameters
    def permit(*keys : String | Symbol) : Hash(String, String)
      result = {} of String => String
      keys.each do |key|
        if value = self[key]?
          result[key.to_s] = value
        end
      end
      result
    end

    def require(key : String | Symbol) : StrongParams
      key_str = key.to_s
      raise ParametersMissing.new("Missing parameter: #{key}") unless has_key?(key)
      StrongParams.new(self, key_str)
    end
  end

  # Strong params for nested parameters
  class StrongParams
    def initialize(@params : ParamHash, @key : String)
    end

    def permit(*keys : String | Symbol) : Hash(String, String)
      result = {} of String => String
      keys.each do |key|
        full_key = "#{@key}[#{key}]"
        if value = @params[full_key]?
          result[key.to_s] = value
        end
      end
      result
    end

    def []?(key : String | Symbol) : String?
      @params["#{@key}[#{key}]"]?
    end

    def [](key : String | Symbol) : String
      self[key]? || raise ParametersMissing.new("Missing parameter: #{@key}[#{key}]")
    end
  end
end

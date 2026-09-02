require "json"

module Orion::Controller
  # JSON Response Helpers
  # Simplified JSON rendering
  #
  # Usage:
  #   get "/api/users" do
  #     json({users: all_users})
  #   end
  module JSONHelpers
    # Render JSON response
    def json(data, status : Int32 = 200)
      response.status_code = status
      response.content_type = "application/json"
      response.print data.to_json
    end

    # Render JSON with specific status
    def json_ok(data)
      json(data, 200)
    end

    def json_created(data, location : String? = nil)
      response.headers["Location"] = location if location
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

    def json_unprocessable_entity(data)
      json(data, 422)
    end

    def json_internal_server_error(data)
      json(data, 500)
    end

    # Render JSONP response
    def jsonp(data, callback : String = "callback", status : Int32 = 200)
      response.status_code = status
      response.content_type = "application/javascript"
      response.print "#{callback}(#{data.to_json})"
    end
  end
end

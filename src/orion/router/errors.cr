abstract class Orion::Router
  ERROR_404 = ->(c : HTTP::Server::Context) {
    c.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    )
    nil
  }

  class ParametersMissing < Exception
    def initialize(keys : Array(String))
      initialize("Missing parameters: #{keys.join(", ")}")
    end
  end
end

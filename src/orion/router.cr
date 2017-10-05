require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  private abstract def get_tree(method : String)

  def initialize(autoclose = true, handlers = [] of HTTP::Handler)
    use Handlers::AutoClose.new if autoclose
    handlers.map { |handler| use handler }
  end

  def call(context : HTTP::Server::Context) : Nil
    # Gather the details
    request = context.request
    method = request.method.downcase
    path = request.path

    # Find the route or 404
    result = get_tree(method).find(path)
    return context.response.respond_with_error(message = "Not Found", code = 404) unless result.found?

    # Build the middleware and call
    handlers = [Handlers::ParamsInjector.new(result.params)] + @handlers + result.payload.handlers
    HTTP::Server.build_middleware(handlers, result.payload.proc).call(context)
  end
end

require "./router/*"
require "./handlers/*"

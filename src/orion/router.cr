macro router(name)
  class {{ name }} < Orion::Router
    {{yield}}
  end
end

abstract class Orion::Router
  include HTTP::Handler

  alias Context = HTTP::Server::Context

  @route_set = RouteSet.new
  @handlers = HandlerList.new
  @forest = Forest.new

  def initialize(autoclose = true)
    use Handlers::AutoClose.new if autoclose
  end

  def call(context : HTTP::Server::Context) : Nil
    # Gather the details
    request = context.request
    method = request.method.downcase
    path = request.path

    # Find the route or 404
    result = @forest[method].find(path)
    return context.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    ) unless result.found?

    # Build the middleware and call
    handlers = [Handlers::ParamsInjector.new(result.params)] + @handlers + result.payload.handlers
    HTTP::Server.build_middleware(handlers, result.payload.proc).call(context)
  end
end

require "./router/*"
require "./handlers/*"

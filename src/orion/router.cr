abstract class Orion::Router
  include HTTP::Handler
  ERR404 = ->(c : HTTP::Server::Context){ c.response.respond_with_error(message: HTTP.default_status_message_for(404), code: 404); nil }

  alias Context = HTTP::Server::Context

  @route_set = RouteSet.new
  @handlers = HandlerList.new
  @forest = Forest.new

  def self.listen(host : String = "127.0.0.1", port = 3000, autoclose : Bool = true, reuse_port : Bool = false)
    router = new(
      host: host,
      port: port,
      handler: self
    )
    router.listen(reuse_port: reuse_port)
  end

  def initialize(host : String = "127.0.0.1", port = 3000, autoclose : Bool = true)
    use Handlers::AutoClose.new if autoclose
    @server = HTTP::Server.new(
      host: host,
      port: port,
      handler: self
    )
  end

  def listen(reuse_port : Bool = false)
    @server.list(reuse_port: reuse_port)
  end

  def call(context : HTTP::Server::Context) : Nil
    # Gather the details
    request = context.request
    method = request.method.downcase
    path = request.path.rchop File.extname(request.path)

    # Find the route or 404
    result = @forest[method].find(path)

    if result.found?
      handlers = [Handlers::ParamsInjector.new(result.params)] + @handlers + result.payload.handlers
      handlers << Handlers::ConstraintsChecker.new(result.payload.constraints)
      proc = result.payload.proc
    else
      handlers = @handlers + self.class.handlers
      proc = ERR404
    end

    HTTP::Server.build_middleware(handlers, proc).call(context)
  end
end

require "./router/*"
require "./handlers/*"

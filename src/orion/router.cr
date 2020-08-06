# The `Orion::Router` is the workhorse that does the work when a request comes
# into your application. It will take all of your defined routes and builds you
# an application that can serve HTTP traffic. You can configure the router using
# the `config` in a single file router. Or by calling the `new` or `start`
# method within your app.
struct Orion::Router
  @stack : HTTP::Handler
  getter handlers = [] of HTTP::Handler
  delegate processor, bind, listen, to: @server
  delegate call, to: @stack

  def self.start(tree : DSL::Tree, *, config : Config)
    new(tree, config.autoclose).tap do |server|
      server.bind(config: config)
      server.listen(workers: config.workers)
      ::Orion::FLAGS["started"] = true
    end
  end

  def self.start(tree : DSL::Tree, *, autoclose : Bool = true, workers = nil, **bind_opts)
    new(tree, autoclose).tap do |server|
      server.bind(**bind_opts)
      server.listen(workers: workers)
      ::Orion::FLAGS["started"] = true
    end
  end

  def initialize(tree : DSL::Tree, autoclose : Bool = true)
    use Handlers::AutoClose if autoclose
    use Handlers::Exceptions.new
    use Handlers::MethodOverrideHeader
    use Handlers::AutoMime
    use Handlers::RouteFinder.new(tree)
    @stack = Server.build_middleware handlers
    @server = Server.new(handler: @stack)
  end

  # Visualize the route tree
  def visualize
    tree.visualize
  end

  def use(handler : HTTP::Handler)
    handlers << handler
  end

  def use(handler)
    use handler.new
  end
end

class Orion::Router
  @stack : HTTP::Handler
  getter handlers = [] of HTTP::Handler
  delegate call, to: @stack

  def self.start(tree : DSL::Tree, autoclose : Bool = true, workers = nil, **bind_opts)
    new(autoclose).tap do |server|
      server.bind(**bind_opts)
      workers ? server.listen(workers) : server.listen
    end
  end

  def initialize(tree : DSL::Tree, autoclose : Bool = true)
    use Handlers::AutoClose if autoclose
    {% unless flag?(:release) %}use Handlers::DebugHandler.new{% end %}
    use Handlers::MethodOverrideHeader
    use Handlers::AutoMime
    use Handlers::Meta
    use Handlers::RouteFinder.new(tree)
    use Handlers::NotFound
    @stack = HTTP::Server.build_middleware handlers
    @server = HTTP::Server.new(handler: @stack)
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

  # Bind to a socket using TLS
  def bind(*, tls, **bind_opts)
    @server.bind_tls(**bind_opts, context: tls)
  end

  # Bind to a port
  def bind(*, port, **bind_opts)
    @server.bind_tcp(**bind_opts, port: port)
  end

  # Bind to a Socket::IPAddress
  def bind(*, address, **bind_opts)
    @server.bind_tcp(**bind_opts, address: address)
  end

  # Bind to a Socket::UnixAddress
  def bind(*, path, **bind_opts)
    @server.bind_unix(**bind_opts, path: path)
  end

  # Bind to a random, unused Socket::IPAddress
  def bind(*args, **bind_opts)
    @server.bind_unused_port(**bind_opts)
  end

  # Listen clients using multiple workers
  # A good suggestion is to use System.cpu_count
  def listen(*, workers, **opts)
    workers.times do |i|
      Process.fork do
        listen(**opts, reuse_port: true, prefix: "#{self.class.name}.#{i}")
      end
    end
    sleep
  end

  # Listen for clients
  def listen(*args, prefix = self.class.name, **opts)
    @server.each_address do |address|
      listen_message(address, prefix)
    end
    @server.listen
  end

  private def listen_message(socket : ::Socket::UNIXAddress, prefix)
    puts "#{prefix}: listening on #{socket.path}"
  end

  private def listen_message(socket : ::Socket::IPAddress, prefix)
    puts "#{prefix}: listening on #{socket.address}:#{socket.port}"
  end
end

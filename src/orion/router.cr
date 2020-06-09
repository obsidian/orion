class Orion::Router
  @stack : HTTP::Handler
  getter handlers = [] of HTTP::Handler
  delegate call, to: @stack

  def self.start(tree : DSL::Tree, autoclose : Bool = true, workers = nil, **bind_opts)
    new(tree, autoclose).tap do |server|
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

  # Bind using a URI
  def bind(*, tls : Nil = nil, uri)
    @server.bind(**bind_opts, uri: uri)
  end

  # Bind TLS with an address
  def bind(*, tls : OpenSSL::SSL::Context::Server, address : ::Socket::IPAddress)
    @server.bind_tls(address: address, context: tls)
  end

  # Bind TLS with a host and port
  def bind(*, tls : OpenSSL::SSL::Context::Server, host, port)
    @server.bind_tls(host: host, port: port, context: tls)
  end

  # Bind using TLS with a host an unused port
  def bind(*, tls : OpenSSL::SSL::Context::Server, host)
    @server.bind_tls(host: host, context: tls)
  end

  # Bind TCP to a host and port
  def bind(*, tls : Nil = nil, host, port, reuse_port = false)
    @server.bind_tcp(host: host, port: port, reuse_port: reuse_port)
  end

  # Bind TCP to a Socket::IPAddress
  def bind(*, tls : Nil = nil, address : ::Socket::IPAddress, reuse_port = false)
    @server.bind_tcp(address: address, reuse_port: reuse_port)
  end

  def bind(*, tls : Nil = nil, address : ::Socket::UNIXAddress)
    @server.bind_unix(address: address)
  end

  # Bind to a Socket::UnixAddress
  def bind(*, tls : Nil = nil, path)
    @server.bind_unix(path: path)
  end

  # Bind using a config
  def bind(*, config : ::Orion::Config)
    case config
    when .uri
      bind(uri: config.uri.not_nil!)
    when .path
      bind(path: config.path.not_nil!)
    when .address
      bind(tls: config.tls, address: config.address.not_nil!)
    else
      port ? bind(host: config.host, port: config.port.not_nil!, reuse_port: config.reuse_port) : bind(host: config.host, reuse_port: config.reuse_port)
    end
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

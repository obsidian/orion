# The `Orion::Router` is the workhorse that does the work when a request comes
# into your application. It will take all of your defined routes and builds you
# an application that can serve HTTP traffic. You can configure the router using
# the `config` in a single file router. Or by calling the `new` or `start`
# method within your app.
struct Orion::Router
  @stack : HTTP::Handler
  @request_processor : HTTP::Server::RequestProcessor?
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
    use Handlers::Exceptions.new
    use Handlers::MethodOverrideHeader
    use Handlers::AutoMime
    use Handlers::RouteFinder.new(tree)
    @stack = HTTP::Server.build_middleware handlers
    @server = HTTP::Server.new(handler: @stack)
  end

  def request_processor
    @request_processor ||= HTTP::Server::RequestProcessor.new(@stack)
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
    @server.bind(uri: uri)
  end

  # Bind TLS with an address
  def bind(*, tls : OpenSSL::SSL::Context::Server, address : ::Socket::IPAddress)
    @server.bind_tls(address: address, context: tls)
  end

  # Bind TLS with a host and port
  def bind(*, tls : OpenSSL::SSL::Context::Server, host = ::Socket::IPAddress::LOOPBACK, port = nil, reuse_port = false)
    if port
      @server.bind_tls(host: host, port: port, context: tls, reuse_port: reuse_port)
    else
      @server.bind_tls(host: host, context: tls)
    end
  end

  # Bind TCP to a host and port
  def bind(*, tls : Nil = nil, host = ::Socket::IPAddress::LOOPBACK, port = nil, reuse_port = false)
    if port
      @server.bind_tcp(host: host, port: port, reuse_port: reuse_port)
    else
      @server.bind_unused_port(host: host, reuse_port: reuse_port)
    end
  end

  # Bind TCP to a Socket::IPAddress
  def bind(*, tls : Nil = nil, address : ::Socket::IPAddress, reuse_port = false)
    @server.bind_tcp(address: address, reuse_port: reuse_port)
  end

  # Bind to a Socket::UnixAddress
  def bind(*, tls = nil, address : ::Socket::UNIXAddress)
    @server.bind_unix(address: address)
  end

  def bind(*, tls = nil, path)
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
      bind(tls: config.tls, host: config.host, port: config.port, reuse_port: config.reuse_port)
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

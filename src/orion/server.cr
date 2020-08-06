class Orion::Server < HTTP::Server
  @name : String = File.basename Dir.current
  getter processor : ::HTTP::Server::RequestProcessor

  # Creates a new Orion server with the given *handler*.
  def initialize(handler : HTTP::Handler | HTTP::Handler::HandlerProc)
    @processor = RequestProcessor.new(handler)
  end

  # Bind using a URI
  def bind(*, tls : Nil = nil, uri)
    bind(uri: uri)
  end

  # Bind TLS with an address
  def bind(*, tls : OpenSSL::SSL::Context::Server, address : ::Socket::IPAddress)
    bind_tls(address: address, context: tls)
  end

  # Bind TLS with a host and port
  def bind(*, tls : OpenSSL::SSL::Context::Server, host = ::Socket::IPAddress::LOOPBACK, port = nil, reuse_port = false)
    if port
      bind_tls(host: host, port: port, context: tls, reuse_port: reuse_port)
    else
      bind_tls(host: host, context: tls)
    end
  end

  # Bind TCP to a host and port
  def bind(*, tls : Nil = nil, host = ::Socket::IPAddress::LOOPBACK, port = nil, reuse_port = false)
    if port
      bind_tcp(host: host, port: port.to_i, reuse_port: reuse_port)
    else
      bind_unused_port(host: host, reuse_port: reuse_port)
    end
  end

  # Bind TCP to a Socket::IPAddress
  def bind(*, tls : Nil = nil, address : ::Socket::IPAddress, reuse_port = false)
    bind_tcp(address: address, reuse_port: reuse_port)
  end

  # Bind to a Socket::UnixAddress
  def bind(*, tls = nil, address : ::Socket::UNIXAddress)
    bind_unix(address: address)
  end

  def bind(*, tls = nil, path)
    bind_unix(path: path)
  end

  # Bind using a config
  def bind(*, config : ::Orion::Config)
    @name = config.name
    case config
    when .path
      bind(path: config.path.not_nil!)
    when .address
      bind(tls: config.tls, address: config.address.not_nil!)
    else
      bind(tls: config.tls, host: config.host.not_nil!, port: config.port, reuse_port: config.reuse_port)
    end
  end

  # Listen clients using multiple workers
  # A good suggestion is to use System.cpu_count
  def listen(*args, workers, **opts)
    if (workers.nil? || workers <= 1)
      listen(*args, **opts)
    else
      workers.times do |i|
        Process.fork do
          listen(*args, **opts, worker: i)
        end
      end
      sleep
    end
  end

  # Listen for clients
  private def listen(*args, worker = nil, **opts)
    each_address do |address|
      listen_message(address, worker ? "#{@name}.#{worker}" : @name)
    end
    super(*args, **opts)
  end

  private def listen_message(socket : ::Socket::UNIXAddress, prefix)
    puts "#{prefix}: listening on #{socket.path}"
  end

  private def listen_message(socket : ::Socket::IPAddress, prefix)
    puts "#{prefix}: listening on #{socket.address}:#{socket.port}"
  end
end

require "./server/*"

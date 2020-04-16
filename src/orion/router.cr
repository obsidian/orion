abstract class Orion::Router; end
require "./router/*"

abstract class Orion::Router
  include HTTP::Handler
  include Concerns
  include Constraints
  include Middleware
  include Helpers
  include Routes
  include Scope
  include Resources
  include BuiltIns

  # :nodoc:
  alias Tree = Oak::Tree(Action)

  # :nodoc:
  alias Context = HTTP::Server::Context
  alias WebSocket = HTTP::WebSocket

  # :nodoc:
  CONTROLLER = nil

  @stack : HTTP::Handler

  delegate call, to: @stack

  # :nodoc:
  def self.normalize_path(path : String)
    base = base_path
    return base if path.empty?
    parts = [base, path].map(&.to_s)
    String.build do |str|
      parts.each_with_index do |part, index|
        part.check_no_null_byte

        str << "/" if index > 0

        byte_start = 0
        byte_count = part.bytesize

        if index > 0 && part.starts_with?("/")
          byte_start += 1
          byte_count -= 1
        end

        if index != parts.size - 1 && part.ends_with?("/")
          byte_count -= 1
        end

        str.write part.unsafe_byte_slice(byte_start, byte_count)
      end
    end
  end

  def self.visualize
    tree.visualize
  end

  def self.start(autoclose : Bool = true, workers = nil, **bind_opts)
    new(autoclose).tap do |server|
      server.bind(**bind_opts)
      workers ? server.listen(workers) : server.listen
    end
  end

  def initialize(autoclose : Bool = true)
    use Handlers::AutoClose if autoclose
    use Handlers::MethodOverrideHeader
    use Handlers::AutoMime
    use Handlers::Meta
    use Handlers::RouteFinder.new(self.class.tree)
    use Handlers::NotFound
    @stack = HTTP::Server.build_middleware handlers
    @server = HTTP::Server.new(handler: @stack)
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

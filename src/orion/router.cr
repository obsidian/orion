abstract class Orion::Router
  include HTTP::Handler

  alias Context = HTTP::Server::Context

  @app : HTTP::Handler?
  @tree = Radix::Tree.new

  delegate call, to: app

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

  def app
    @app ||= if handlers.empty?
      @tree
    else
      HTTP::Server.build_middleware(@handlers, ->(context : HTTP::Server::Context){ @tree.call(context) ; nil })
    end
  end

  def listen(reuse_port : Bool = false)
    listen {}
  end

  def listen(reuse_port : Bool = false)
    tcp_server = @server.bind(reuse_port)
    yield self
    until @server.@wants_close
      spawn tcp_server.handle_client(tcp_server.accept?)
    end
  end

  # :nodoc:
  def self.normalize_path(path : String)
    base = base_path
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
end

require "./router/*"
require "./handlers/*"

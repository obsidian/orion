abstract class Orion::Router
  include HTTP::Handler

  alias Context = HTTP::Server::Context

  @app : HTTP::Handler
  @tree = Radix::Tree.new

  delegate call, to: @app

  def self.listen(*, autoclose = true, host = "127.0.0.1", port = 3000, reuse_port = false)
    router = new(autoclose: autoclose)
    server = HTTP::Server.new(host: host, port: port, handler: router)
    server.listen(reuse_port: reuse_port)
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

  def self.visualize
    tree.visualize
  end

  def initialize(autoclose : Bool = true)
    use Handlers::AutoClose.new if autoclose
    @app = build
  end

  def build
    return @tree if handlers.empty?
    HTTP::Server.build_middleware handlers, ->(context : HTTP::Server::Context) do
      @tree.call(context)
      nil
    end
  end

end

require "./router/*"
require "./handlers/*"

abstract class Orion::Router
  # :nodoc:
  alias Tree = Oak::Tree(Action)
  alias Context = HTTP::Server::Context
  CONTROLLER = nil

  @app : HTTP::Handler::Proc

  delegate call, to: @app

  def self.listen(*, autoclose = true, host = "127.0.0.1", port = 3000, reuse_port = false)
    router = new(autoclose: autoclose)
    server = HTTP::Server.new(host: host, port: port, handler: router)
    server.listen(reuse_port: reuse_port)
  end

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

  def initialize(autoclose : Bool = true)
    use Orion::Middleware::AutoClose if autoclose
    use Orion::Middleware::MethodOverrideHeader
    use Orion::Middleware::AutoMime
    use Orion::Middleware::Meta
    use Orion::Middleware::RouteFinder.new(self.class.tree)
    use ERROR_404
    @app = Middleware::Chain.new(middleware).to_proc
  end
end

require "./router/*"

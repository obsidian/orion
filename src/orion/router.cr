abstract class Orion::Router; end

require "./router/*"

abstract class Orion::Router
  class ParametersMissing < Exception
    def initialize(keys : Array(String))
      initialize("Missing parameters: #{keys.join(", ")}")
    end
  end

  include HTTP::Handler
  include Concerns
  include Constraints
  include Middleware
  include Helpers
  include Routes
  include Scope
  include Resources

  # :nodoc:
  alias Tree = Oak::Tree(Action)

  # :nodoc:
  alias Context = HTTP::Server::Context

  # :nodoc:
  CONTROLLER = nil

  @app : HTTP::Handler

  delegate call, to: @app

  def self.listen(*, autoclose = true, host = "127.0.0.1", port = 3000, reuse_port = false)
    router = new(autoclose: autoclose)
    server = HTTP::Server.new(handler: router)
    server.listen(host: host, port: port, reuse_port: reuse_port)
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
    use Handlers::AutoClose if autoclose
    use Handlers::MethodOverrideHeader
    use Handlers::AutoMime
    use Handlers::Meta
    use Handlers::RouteFinder.new(self.class.tree)
    use Handlers::NotFound
    @app = HTTP::Server.build_middleware handlers
  end
end

abstract class Orion::Router
  private macro inherited
    setup_constraints
    setup_handlers
    setup_concerns

    {% if @type.superclass == ::Orion::Router %}
      alias ROUTER = self

      module Helpers
        extend self
      end

      BASE_PATH = "/"
      TREE = ::Oak::Tree(::Orion::Action).new
      PREFIXES = [] of String

      # Instance vars
      @tree = TREE

      def self.routes
        ROUTE_SET
      end

      def self.tree
        TREE
      end
    {% end %}

    def self.base_path
      BASE_PATH
    end
  end

  # :nodoc:
  alias Context = HTTP::Server::Context
  CONTROLLER = nil
  ERROR_404 = ->(c : HTTP::Server::Context){
    c.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    )
  }

  @app : HTTP::Handler
  @tree = Oak::Tree(Action).new

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
    use Handlers::AutoMime.new
    use Handlers::Meta.new
    @app = build
  end

  def build
    HTTP::Server.build_middleware handlers, ->(context : HTTP::Server::Context) do
      leaf = nil
      path = context.request.path
      @tree.search(path.rchop(File.extname(path))) do |result|
        unless leaf
          context.request.path_params = result.params
          leaf = result.leaves.find &.matches_constraints? context.request
          leaf.try &.call(context)
        end
      end

      # lastly return with 404
      unless leaf
        context.response.respond_with_error(message: HTTP.default_status_message_for(404), code: 404)
        context.response.close
      end
    end
  end
end

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
end

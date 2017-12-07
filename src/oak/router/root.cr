abstract class Oak::Router
  private macro setup_root
    {% if @type.superclass == ::Oak::Router %}
      alias ROUTER = self

      module Helpers
        extend self
      end

      BASE_PATH = "/"
      TREE = ::Oak::Tree.new
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
  end

  # Define a `GET /` route at the current path.
  # for params see: `.match`
  macro root(callable, **params)
    {% if params.empty? %}
      get "/", {{callable}}, helper: "root"
    {% else %}
      get "/", {{callable}}, {{**params}}, helper: "root"
    {% end %}
  end
end

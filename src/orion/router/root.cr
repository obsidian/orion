abstract class Orion::Router
  private macro setup_root
    {% if @type.superclass == ::Orion::Router %}
      alias ROUTER = self

      module Helpers
        extend self
      end

      BASE_PATH = "/"
      TREE = Orion::Radix::Tree.new
      PREFIXES = [] of String

      # Instance vars
      @tree = TREE

      def self.routes
        ROUTE_SET
      end

      def self.tree
        TREE
      end

      def self.viz
        tree.viz
      end
    {% end %}
  end

  # Define a `GET /` route at the current path.
  macro root(callable = nil, *, to = nil, controller = nil, action = nil)
    get "/", {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, helper: "root"
  end
end

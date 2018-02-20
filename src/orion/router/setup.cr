abstract class Orion::Router
  private macro inherited
    setup_constraints
    setup_middleware
    setup_concerns

    {% if @type.superclass == ::Orion::Router %}
      alias ROUTER = self

      module Helpers
        extend self
      end

      BASE_PATH = "/"
      TREE = ::Orion::Router::Tree.new
      PREFIXES = [] of String

      def self.routes
        tree.results
      end

      def self.tree
        TREE
      end
    {% end %}

    def self.base_path
      BASE_PATH
    end
  end
end

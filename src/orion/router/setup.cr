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

      class BaseController < Orion::Controller::Base
        include Helpers
      end

      class BaseSocket < Orion::Socket::Base
        include Helpers
      end

      BASE_PATH = "/"
      TREE = Tree.new
      PREFIXES = [] of String

      # Instance vars
      @tree = TREE

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

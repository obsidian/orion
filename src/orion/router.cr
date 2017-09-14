require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  @route_cache = {} of String => HTTP::Handler

  alias Tree = Radix::Tree(NamedTuple(handlers: Array(HTTP::Handler), route: HTTP::Server::Context -> Nil))

  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  @@handlers = [] of HTTP::Handler
  def self.handlers
    @@handlers
  end

  @@trees = {} of String => Tree

  def self.trees
    @@trees
  end

  @@routes = {} of String => Hash(Symbol, String)
  def self.routes
    @@routes
  end

  private def self.base_path
    ""
  end

  private def self.normalize_path(path)
    File.join([base_path, path])
  end

  private def self.use(handler : HTTP::Handler)
    @@handlers << handler
  end

  macro inherited

    {% for method in METHODS + %w{match} %}
      @@trees[{{method.downcase}}] = Tree.new
    {% end %}

    GROUP_COUNTER = [0]

    def self.handlers
      {{ @type.superclass }}.handlers + @@handlers
    end

    def get_tree(method)
      self.class.trees.try(&.[method]?) || Tree.new
    end

    def call(context) : Nil
      request = context.request
      method = request.method.downcase
      path = request.path
      result = get_tree(method).find(path)
      result = get_tree("match").find(path) unless result.found?
      return context.response.respond_with_error(message = "Not Found", code = 404) unless result.found?
      handlers = result.payload[:handlers]
      handlers.unshift Orion::RouteParamsHandler.new(result.params)
      HTTP::Server.build_middleware(handlers, result.payload[:route]).call(context)
    end
  end

  {% for method in METHODS + %w{match} %}
    macro {{method.downcase.id}}(path, action)
      \{% label = action.id.stringify %}
      \{% if action.is_a? StringLiteral %}
        \{% controller = action.split("#")[0] %}
        \{% method = action.split("#")[1] || method %}
        \{% raise("string must be in the form `Controller#action`") unless controller && method %}
        \{%
          action = <<-crystal
            -> (context : HTTP::Server::Context) { #{controller.id}.new(context).#{method.id} ; nil }
          crystal
        \%}
      \{% else %}
        \{%
          action = <<-crystal
            -> (context : HTTP::Server::Context) { #{action.id}.call(context) ; nil }
          crystal
        \%}
      \{% end %}
      (routes[File.join([base_path, \{{path}}])] ||= {} of Symbol => String)[:{{method.id}}] = \{{label}}
      trees[{{method.downcase}}].add(File.join([base_path, \{{path}}]), {handlers: self.handlers, route: \{{ action.id }}})
    end

    macro {{method.downcase.id}}(pattern)
      \{% action = "-> (context : HTTP::Server::Context) { #{yield}; nil }" %}
      {{method.downcase.id}}(\{{pattern}}, \{{action.id}})
    end
  {% end %}

  macro mount(path, app)
    match({{path}}, {{app}})
  end

  macro mount(app)
    mount("/", {{app}})
  end

  macro group(path = nil)
    {% counter = GROUP_COUNTER[0] = GROUP_COUNTER[0] + 1 %}
    {% superclass = @type %}
    class RouterGroup{{counter}} < {{superclass}}
      def self.trees
        {{superclass}}.trees
      end

      def self.routes
        {{superclass}}.routes
      end

      {% if path %}
      private def self.base_path
        File.join([super, {{path}}])
      end
      {% end %}

      {{yield}}
    end
  end
end

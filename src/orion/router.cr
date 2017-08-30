require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  alias Tree = Radix::Tree((HTTP::Server::Context, Hash(String, String)) -> Nil)

  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  private def self.handlers
    @@handlers ||= [] of HTTP::Handler
  end

  private def self.base_path
    ""
  end

  private GROUP_COUNTER = [0]

  macro inherited
    private GROUP_COUNTER = [0]

    TREES = {
      {% for method in METHODS + %w{match} %}
        {{method.downcase}} => Tree.new,
      {% end %}
    }

    def self.handlers
      @@handlers ||= super + [] of HTTP::Handler
    end

    def get_tree(method)
      TREES.try(&.[method]?) || Tree.new
    end

    def call(context) : Nil
      request = context.request
      method = request.method.downcase
      path = request.path
      result = get_tree(method).find(path)
      result = get_tree("match").find(path) unless result.found?
      return context.response.respond_with_error(message = "Not Found", code = 404) unless result.found?
      result.payload.call(context, result.params)
    end
  end

  {% for method in METHODS + %w{match} %}
    macro {{method.downcase.id}}(path, action)
      \{% if action.is_a? StringLiteral %}
        \{% controller = action.split("#")[0] %}
        \{% method = action.split("#")[1] || method %}
        \{% raise(action_error) unless controller && action %}
        \{%
          action = "-> (context : HTTP::Server::Context, params : Hash(String, String)) {
            route = ->(cxt : HTTP::Server::Context) {
              params.each_with_object(cxt.request.query_params) do |(k, v), params|
                params[k] = v
              end
              #{controller.id}.new(context).#{method.id}
            }

            (handlers.first? ? HTTP::Server.build_middleware(handlers, route) : route).call(context)
          }"
        \%}
      \{% elsif !action.is_a?(ProcLiteral) %}
         \{% raise("action must be either a string of the form `Controller#action' or a Proc") %}
      \{% end %}
      # puts trees
      # puts trees
      puts File.join([base_path, \{{path}}])
      TREES[{{method.downcase}}].add(File.join([base_path, \{{path}}]), \{{ action.id }})
    end

    macro {{method.downcase.id}}(pattern)
      {% action = "-> (path : HTTP::Server::Context, params : HTTP::Params) : Nil { #{yield} }" %}
      {{method.downcase.id}}(\{{pattern}}, {{action.id}})
    end
  {% end %}

  macro group(path)
    {% counter = GROUP_COUNTER[0] = GROUP_COUNTER[0] + 1 %}
    {% superclass = @type %}
    class RouterGroup{{counter}} < {{superclass}}
      TREES.merge! {{superclass}}::TREES

      private def self.base_path
        File.join([super, {{path}}])
      end

      {{yield}}
    end
  end

  macro group
    {% counter = GROUP_COUNTER[0] = GROUP_COUNTER[0] + 1 %}
    {% superclass = @type %}
    class RouterGroup{{counter}} < {{superclass}}
      TREES.merge! {{superclass}}::TREES

      {{yield}}
    end
  end

  private def self.normalize_path(path)
    File.join([base_path, path])
  end

  private def self.use(handler : HTTP::Handler)
    handlers << handler
  end

end

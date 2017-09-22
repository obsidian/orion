require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  alias Tree = Radix::Tree(NamedTuple(handlers: Array(HTTP::Handler), route: HTTP::Server::Context -> Nil))

  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  HANDLERS = [] of HTTP::Handler

  macro inherited
    GROUP_COUNTER = [0]

    {% if @type.superclass == Orion::Router %}
      BASE_PATH = "/"
      ROUTES = {} of String => Hash(Symbol, String)
      {% for method in METHODS %}
        {{method.id}}_TREE = Tree.new
      {% end %}

      def call(context) : Nil
        request = context.request
        method = request.method.downcase
        path = request.path

        tree = {% begin %}
          case method
          {% for method in METHODS %}
          when {{method.downcase}}
            {{method.id}}_TREE
          {% end %}
          else
            Tree.new
          end
        {% end %}

        result = tree.find(path)
        return context.response.respond_with_error(message = "Not Found", code = 404) unless result.found?
        handlers = result.payload[:handlers]
        handlers.unshift Orion::RouteParamsHandler.new(result.params)
        HTTP::Server.build_middleware(handlers, result.payload[:route]).call(context)
      end

    {% else %}
      HANDLERS = {{@type.superclass}}::HANDLERS + ([] of HTTP::Handler)
    {% end %}

    private def self.normalize_path(path)
      parts = [BASE_PATH, path]
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

    private def self.use(handler : HTTP::Handler)
      HANDLERS << handler
    end
  end

  {% for method in METHODS %}
    private macro {{method.downcase.id}}(path, action)
      \{% label = action.id.stringify %}
      \{% label = "proc" if label.starts_with? "->" %}
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
      (ROUTES[File.join([BASE_PATH, \{{path}}])] ||= {} of Symbol => String)[:{{method.id}}] = \{{label}}
      {{method.id}}_TREE.add(normalize_path(\{{path}}), {handlers: HANDLERS, route: \{{ action.id }}})
    end
  {% end %}

  private macro match(path, action, via = nil)
    {% via = via || METHODS %}
    {% for method in via.select { |method| METHODS.includes? method.upcase } %}
      {{method.downcase.id}}({{path}}, {{action}})
    {% end %}
  end

  private macro mount(path, app)
    match({{path}}, {{app}})
  end

  private macro mount(app)
    mount("/", {{app}})
  end

  private macro clear_handlers
    group do
      {{yield}}
      HANDLERS.clear
    end
  end

  private macro group(path = "")
    {% counter = GROUP_COUNTER[0] = GROUP_COUNTER[0] + 1 %}
    {% superclass = @type %}
    class RouterGroup{{counter}} < {{superclass}}
      BASE_PATH = File.join({{superclass}}::BASE_PATH, {{path}})

      def self.trees
        {{superclass}}.trees
      end

      def self.routes
        {{superclass}}.routes
      end

      {{yield}}
    end
  end
end

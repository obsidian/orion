require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  record Payload, handlers : Array(HTTP::Handler), action : HTTP::Handler::Proc, label : String

  alias Tree = Radix::Tree(Payload)

  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  HANDLERS = [] of HTTP::Handler

  macro inherited
    GROUP_COUNTER = [0]

    {% if @type.superclass == Orion::Router %}
      BASE_PATH = "/"
      ROUTES = {} of String => Hash(Symbol, Payload)
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
        handlers = [Orion::RouteParamsHandler.new(result.params)] + result.payload.handlers
        HTTP::Server.build_middleware(handlers, result.payload.action).call(context)
      end

      def self.route_table
        rows = SampleRouter::ROUTES.each_with_object([] of Array(String)) do |(path, methods), rows|
          methods.each do |method, payload|
            color = case method
            when :GET, :HEAD
              :light_green
            when :PUT, :PATCH
              :light_yellow
            when :DELETE
              :light_red
            else
              :cyan
            end
            method_string = method.to_s.colorize(color).to_s
            rows << [path, method_string, payload.label]
          end
        end
        ShellTable.new(
          labels: ["Path", "Method", "Action"],
          label_color: :yellow,
          rows: rows
        )
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
      payload = Payload.new(handlers: HANDLERS, action: \{{ action.id }}, label: \{{label}})
      (ROUTES[File.join([BASE_PATH, \{{path}}])] ||= {} of Symbol => Payload)[:{{method.id}}] = payload
      {{method.id}}_TREE.add(normalize_path(\{{path}}), payload)
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

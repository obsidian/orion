require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {% for method in METHODS %}
    # Add a **{{method.id}}** route with the given path and action.
    macro {{method.downcase.id}}(path, action)
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
      {{method.id}}_TREE.add(normalize_path(\{{path}}), payload)
      (ROUTES[File.join([BASE_PATH, \{{path}}])] ||= {} of Symbol => Payload)[:{{method.id}}] = payload
    end

    macro {{method.downcase.id}}(path, *, controller, action)
      {{method.downcase.id}}(\{{path}}, "\{{controller}}\#{{action}}")
    end
  {% end %}
end

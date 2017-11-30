require "radix"

abstract class Orion::Router
  macro match(path, callable = nil, *, to = nil, controller = nil, action = match, helper = nil, constraints = nil, format = nil, accept = nil, via = :all)
    {% arg_count = 0 }
    {% arg_count = arg_count + 1 if callable %}
    {% arg_count = arg_count + 1 if controller %}
    {% arg_count = arg_count + 1 if to %}

    {% if arg_count == 0 %} # Raise arg errors
      {% raise "must supply one of: `callable`, `to`, or `controller`" %}
    {% elsif arg_count > 1 %}
      {% raise "must supply only one of: `callable`, `to`, or `controller`" %}
    {% end %}

    {% if to && !controller %} # Convert to into `controller` & `action`.
      {% parts = to.split("#") %}
      {% controller = run("./inflector/controllerize.cr", parts[0].id) + "Controller" %}
      {% action = parts[1].id %}
      {% raise("`to` must be in the form `controller#action`") unless controller && action && parts.size == 2 %}
    {% end %}

    {% if callable %} # Build the proc from callable
      %label = {{callable.id.stringify}}
      %proc = -> (context : HTTP::Server::Context) {
        {{callable}}.call(context)
        nil
      }
    {% end %}

    {% if controller %} # Build the proc from a controller
      {% action = action %}
      %label = [{{controller.stringify}}, {{action.stringify}}].join("#")
      %proc = -> (context : HTTP::Server::Context) {
        {{controller}}.new(context).{{action}}
        nil
      }
    {% end %}

    # Build the payload
    %payload = Orion::Radix::Payload.new(
      %proc,
      handlers: HANDLERS,
      constraints: CONSTRAINTS,
      label: %label
    )

    # Add the route to the tree
    %full_path = normalize_path({{path}})
    TREE.add(%full_path, %payload)

    {% if helper %} # Define the helper
      define_helper(path: {{path}}, spec: {{helper}})
    {% end %}

    {% if via != :all %} # Define the method constraint
      {% constraints_class = run "./inflector/random_const.cr", "MethodConstraint" %}
      struct {{constraints_class}} < ::Orion::Radix::Constraint
        def matches?
          {% if via.is_a? ArrayLiteral %}
            {{ via.map(&.id.stringify.downcase) }}.any?(&.== request.method.downcase)
          {% else %}
            {{ via.id.stringify.downcase }} == request.method.downcase
          {% end %}
        end
      end
      %payload.constraints << {{constraints_class}}
    {% end %}

    {% if constraints %} # Define the param constraints
      {% constraints_class = run "./inflector/random_const.cr", "ParamConstraint" %}
      # :nodoc:
      struct {{constraints_class}} < ::Orion::Radix::Constraint
        def matches?
          {% for key, value in constraints %}
            return false unless {{ value }}.match request.query_params[{{ key.id.stringify }}]?.to_s
          {% end %}
          true
        end
      end
      %payload.constraints << {{constraints_class}}
    {% end %}

    {% if format %} # Define the format constraint
      {% constraints_class = run "./inflector/random_const.cr", "FormatConstraints" %}
      # :nodoc:
      struct {{constraints_class}} < ::Orion::Radix::Constraint
        def matches?
          File.extname(request.path).lchop('.') == {{format}} ||
            File.extname(request.path).lchop('.') =~ {{format}}
        end
      end
      %payload.constraints << {{constraints_class}}
    {% end %}

    {% if accept %} # Define the content type constraint
      {% constraints_class = run "./inflector/random_const.cr", "ContentTypeConstraints" %}
      # :nodoc:
      struct {{constraints_class}} < ::Orion::Radix::Constraint
        def matches?
          (request.headers["Accept"]? || "*/*").split(',').map(&.split(';')[0]).any? do |content_type|
            {% if accept.is_a?(ArrayLiteral) %}
              {{ accept }}.any? { |m| m == content_type || m =~ content_type }
            {% else %}
              content_type == {{ accept }} ||
                content_type =~ {{ accept }}
            {% end %}
          end
        end
      end
      %payload.constraints << {{constraints_class}}
    {% end %}
  end
end

require "radix"

abstract class Orion::Router
  macro match(path, callable = nil, *, to = nil, controller = nil, action = match, helper = nil, constraints = nil, format = nil, accept = nil, via = :all)
    {% if !format && path.split(".").size > 1 %}
      {% format = path.split(".")[-1] %}
      {% path = path.split(".")[0..-2].join(".") %}
    {% end %}
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

    {% if via != :all && !via.nil? %} # Define the method constraint
      %payload.constraints << ::Orion::MethodsConstraint.new({{via}})
    {% end %}

    {% if constraints %} # Define the param constraints
      %payload.constraints << ::Orion::ParamsConstraint.new({{constraints}}.to_h)
    {% end %}

    {% if format %} # Define the format constraint
      %payload.constraints << ::Orion::FormatConstraint.new({{format}})
    {% end %}

    {% if accept %} # Define the content type constraint
      %payload.constraints << ::Orion::FormatConstraint.new({{accept}})
    {% end %}
  end
end

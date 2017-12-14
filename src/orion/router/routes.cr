module Orion::Router::Routes
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    match({{ at }}, {{ app }})
  end

  # Define a `GET /` route at the current path.
  # for params see: `.match`
  macro root(callable, **params)
    {% if params.empty? %}
      get "/", {{ callable }}, helper: "root"
    {% else %}
      get "/", {{ callable }}, {{**params}}, helper: "root"
    {% end %}
  end

  {% for method in ::HTTP::VERBS %}
    # Defines a {{ method }} route
    # for args and params see: `.match`
    macro {{method.downcase.id}}(*args, **params)
      \{% if params.empty? %}
        match(\{{*args}}, action: {{method.downcase.id}}, via: {{method.downcase}})
      \{% else %}
        \{% if params[:action] %}
          match(\{{*args}}, \{{**params}}, via: {{method.downcase}})
        \{% else %}
          match(\{{*args}}, \{{**params}}, action: {{method.downcase.id}}, via: {{method.downcase}})
        \{% end %}
      \{% end %}
    end
  {% end %}

  # Defines a match route.
  #
  # ### Variations:
  #
  # #### Routing to controller and action (short form).
  # You can route to a controller and action by passing the `to` argument in
  # the form of `"Controller#action"`.
  #
  # ```
  # class MyController
  #   def new(@context : HTTP::Server::Context)
  #   end
  #
  #   def match
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   match "/path", to: "MyController#match"
  # end
  # ```
  #
  # #### Routing to controller and action (long form).
  # You can route to a controller and action by passing the `controller` and
  # `action` arguments, if action is omitted it will default to `match`.
  #
  # ```
  # class MyController
  #   def new(@context : HTTP::Server::Context)
  #   end
  #
  #   def match
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   match "/path", controller: MyController, action: match
  # end
  # ```
  #
  # #### Routing to callable objects.
  # You can route to any object that responds to `call` with an `HTTP::Server::Context`,
  # this also works for any `Proc(HTTP::Server::Context, _)`.
  #
  # ```
  # module Callable
  #   def call(cxt : HTTP::Server::Context)
  #   # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   match "/path", Callable
  #   match "/path", ->(HTTP::Server::Context) {
  #     # ... do something
  #   }
  # end
  # ```
  macro match(path, callable = nil, *, to = nil, controller = nil, action = match, helper = nil, constraints = nil, format = nil, accept = nil, via = :all)
    {% if !format && path.split(".").size > 1 %}
      {% format = path.split(".")[-1] %}
      {% path = path.split(".")[0..-2].join(".") %}
    {% end %}

    {% if !callable && !controller && !to && CONTROLLER %}
      {% controller = CONTROLLER %}
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

    {% if !callable && controller %} # Build the proc from a controller
      {% action = action %}
      %label = [{{controller.stringify}}, {{action.stringify}}].join("#")
      %proc = -> (context : HTTP::Server::Context) {
        {{ controller }}.new(context).{{ action }}
        nil
      }
    {% end %}

    {% if callable %} # Build the proc from callable
      %label = {{callable.id.stringify}}
      %proc = -> (context : HTTP::Server::Context) {
        {{ callable }}.call(context)
        nil
      }
    {% end %}

    # Build the payload
    %leaf = ::Orion::Action.new(
      %proc,
      handlers: HANDLERS,
      constraints: CONSTRAINTS,
      label: %label
    )

    # Add the route to the tree
    %full_path = normalize_path({{ path }})
    TREE.add(%full_path, %leaf)

    {% if helper %} # Define the helper
      define_helper(path: {{ path }}, spec: {{ helper }})
    {% end %}

    {% if via != :all && !via.nil? %} # Define the method constraint
      %leaf.constraints << ::Orion::MethodsConstraint.new({{ via }})
    {% end %}

    {% if constraints %} # Define the param constraints
      %leaf.constraints << ::Orion::ParamsConstraint.new({{ constraints }}.to_h)
    {% end %}

    {% if format %} # Define the format constraint
      %leaf.constraints << ::Orion::FormatConstraint.new({{ format }})
    {% end %}

    {% if accept %} # Define the content type constraint
      %leaf.constraints << ::Orion::AcceptConstraint.new({{ accept }})
    {% end %}
  end
end

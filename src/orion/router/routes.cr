require "../../http"

module Orion::Router::Routes
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    match({{ at }}, {{ app }})
  end

  # Defines a websocket route to a callable object.
  #
  # You can route to any object that responds to `call` with a `HTTP::WebSocket` and an `HTTP::Server::Context`.
  #
  # ```
  # module Callable
  #   def call(ws : HTTP::WebSocket, cxt : HTTP::Server::Context)
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   ws "/path", Callable
  # end
  # ```
  macro ws(path, ws_callable, *, helper = nil)
    puts "ws"
    # Build the proc
    %proc = ->(web_socket : HTTP::WebSocket, context : HTTP::Server::Context) {
      {{ ws_callable }}.call(web_socket, context)
      nil
    }
    %callable = HTTP::Server.build_middleware([
      HTTP::WebSocketHandler.new(&%proc),
      ::Orion::Handlers::NotFound.new
    ])
    get({{ path }}, %callable, helper: {{ helper }})
  end

  # Defines a websocket route to a websocket compatible controller and action (short form).
  # You can route to a controller and action by passing the `to` argument in
  # the form of `"MyWebSocketController#action"`.
  #
  # ```
  # class MyWebSocketController
  #   def new(@ws : HTTP::WebSocket, @context : HTTP::Server::Context)
  #   end
  #
  #   def ws
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   ws "/path", to: "MyWebSocketController#ws"
  # end
  # ```
  macro ws(path, *, to, helper = nil)
    {% parts = to.split("#") %}
    {% controller = run("./inflector/controllerize.cr", parts[0].id) %}
    {% action = parts[1] %}
    {% raise("`to` must be in the form `controller#action`") unless controller && action && parts.size == 2 %}
    ws({{ path }}, controller: {{ controller.id }}, action: {{ action.id }}, helper: {{ helper }})
  end

  # Defines a match route to a controller and action (long form).
  # You can route to a controller and action by passing the `controller` and
  # `action` arguments, if action is omitted it will default to `match`.
  #
  # ```
  # class MyWebSocketController
  #   def new(@ws : HTTP::WebSocket, @context : HTTP::Server::Context)
  #   end
  #
  #   def ws
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   ws "/path", controller: MyWebSocketController, action: ws
  # end
  # ```
  macro ws(path, *, action, controller = CONTROLLER, helper = nil)
    ws({{ path }}, ->(web_socket : HTTP::WebSocket, context : HTTP::Server::Context) { {{ controller }}.new(web_socket, context).{{ action }} }, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end

  # Defines a match route with a block.
  #
  # You can route to any object that responds to `call` with an `HTTP::Server::Context`.
  #
  # ```
  # router MyRouter do
  #   ws "/path" do |web_socket, context|
  #     # ... do something
  #   end
  # end
  # ```
  macro ws(path, *, helper = nil, &block)
    {%
      args = [
        "#{block.args[0]} : HTTP::WebSocket".id,
        "#{block.args[1]} : HTTP::Server::Context".id,
      ].join(", ").id
    %}
    ws({{ path }}, ->({{ args }}){ {{ block.body }} }, helper: {{ helper }})
  end

  # Define a `GET /` route at the current path with a callable object.
  #
  # ```
  # module Callable
  #   def call(cxt : HTTP::Server::Context)
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   root Callable
  # end
  # ```
  macro root(callable, *, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    get("/", {{ callable }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }}, helper: "root")
  end

  # Define a `GET /` route at the current path with a controller and action (short form).
  #
  # ```
  # router MyRouter do
  #   root to: "Controller#action"
  # end
  # ```
  macro root(*, to, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    get("/", to: {{ to }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }}, helper: "root")
  end

  # Define a `GET /` route at the current path with a controller and action (long form).
  #
  # ```
  # router MyRouter do
  #   root controller: Controller action: action
  # end
  # ```
  macro root(*, action, controller = CONTROLLER, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
    get("/", action: {{ action }}, controller: {{ controller }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }}, helper: "root")
  end

  # Define a `GET /` route at the current path with a callable object.
  #
  # ```
  # router MyRouter do
  #   root do |context|
  #     # ...
  #   end
  # end
  # ```
  macro root(*, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
    {% args = block.args.map { |n| "#{n} : HTTP::Server::Context".id }.join(", ").id %}
    get("/", ->({{ args }}){ {{ block.body }} }, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }}, helper: "root")
  end

  {% for method in ::HTTP::VERBS %}
    # Defines a {{ method.id }} route to a callable object.
    #
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
    # end
    # ```
    macro {{ method.downcase.id }}(path, callable, *, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
      match(\{{ path }}, \{{ callable }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end

    # Defines a {{ method.id }} route to a controller and action (short form).
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
    #   match "/path", to: "MyController#{{ method.downcase.id }}"
    # end
    # ```
    macro {{ method.downcase.id }}(path, *, to, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
      match(\{{ path }}, to: \{{ to }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end

    # Defines a {{ method.id }} route to a controller and action (long form).
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
    #   match "/path", controller: MyController, action: {{ method.downcase.id }}
    # end
    # ```
    macro {{ method.downcase.id }}(path, *, action, controller = CONTROLLER, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
      match(\{{ path }}, controller: \{{ controller }}, action: \{{ action }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end

    # Defines a {{ method.id }} route with a block.
    #
    # You can route to any object that responds to `call` with an `HTTP::Server::Context`,
    # this also works for any `Proc(HTTP::Server::Context, _)`.
    #
    # ```
    # router MyRouter do
    #   match "/path" do |context|
    #     # ... do something
    #   end
    # end
    # ```
    macro {{ method.downcase.id }}(path, *, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
      \{% args = block.args.map { |n| "#{n} : HTTP::Server::Context".id }.join(", ").id %}
      match(\{{ path }}, ->(\{{ args }}){ \{{ block.body }} }, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end
  {% end %}

  # Defines a match route to a callable object.
  #
  # You can route to any object that responds to `call` with an `HTTP::Server::Context`.
  #
  # ```
  # module Callable
  #   def call(cxt : HTTP::Server::Context)
  #     # ... do something
  #   end
  # end
  #
  # router MyRouter do
  #   match "/path", Callable
  # end
  # ```
  macro match(path, callable, *, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    {% if !format && path.split(".").size > 1 %}
      {% format = path.split(".")[-1] %}
      {% path = path.split(".")[0..-2].join(".") %}
    {% end %}

    # Build the proc
    %proc = -> (context : HTTP::Server::Context) {
      {{ callable }}.call(context)
      nil
    }

    # Build the payload
    %leaf = ::Orion::Action.new(
      %proc,
      handlers: HANDLERS,
      constraints: CONSTRAINTS
    )

    # Add the route to the tree
    %full_path = normalize_path({{ path }})
    TREE.add(%full_path, %leaf)

    {% if helper %} # Define the helper
      define_helper(path: {{ path }}, spec: {{ helper }})
    {% end %}

    {% if constraints %} # Define the param constraints
      %leaf.constraints.unshift ::Orion::ParamsConstraint.new({{ constraints }}.to_h)
    {% end %}

    {% if content_type %} # Define the content type constraint
      %leaf.constraints.unshift ::Orion::ContentTypeConstraint.new({{ content_type }})
    {% end %}

    {% if type %} # Define the content type and accept constraint
      %leaf.constraints.unshift ::Orion::ContentTypeConstraint.new({{ type }})
      %leaf.constraints.unshift ::Orion::AcceptConstraint.new({{ type }})
    {% end %}

    {% if format %} # Define the format constraint
      %leaf.constraints.unshift ::Orion::FormatConstraint.new({{ format }})
    {% end %}

    {% if accept %} # Define the content type constraint
      %leaf.constraints.unshift ::Orion::AcceptConstraint.new({{ accept }})
    {% end %}

    {% if via != :all && !via.nil? %} # Define the method constraint
      %leaf.constraints.unshift ::Orion::MethodsConstraint.new({{ via }})
    {% end %}
  end

  # Defines a match route to a controller and action (short form).
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
  macro match(path, *, to, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    {% parts = to.split("#") %}
    {% controller = run("./inflector/controllerize.cr", parts[0].id) %}
    {% action = parts[1] %}
    {% raise("`to` must be in the form `controller#action`") unless controller && action && parts.size == 2 %}
    match({{ path }}, controller: {{ controller.id }}, action: {{ action.id }}, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end

  # Defines a match route to a controller and action (long form).
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
  macro match(path, *, action, controller = CONTROLLER, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    match({{ path }}, ->(context : HTTP::Server::Context) { {{ controller }}.new(context).{{ action }} }, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end

  # Defines a match route with a block.
  #
  # You can route to any object that responds to `call` with an `HTTP::Server::Context`.
  #
  # ```
  # router MyRouter do
  #   match "/path" do |context|
  #     # ... do something
  #   end
  # end
  # ```
  macro match(path, *, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
    {% args = block.args.map { |n| "#{n} : HTTP::Server::Context".id }.join(", ").id %}
    match({{ path }}, ->({{ args }}){ {{ block.body }} }, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end
end

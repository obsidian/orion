# The websocket handlers allow you to easily add websocket support to your
# application.
module Orion::DSL::WebSockets
  # Defines a websocket route to a callable object.
  #
  # You can route to any object that responds to `call` with a `HTTP::WebSocket` and an `HTTP::Server::Context`.
  #
  # ```
  # router MyRouter do
  #   ws "/path", Callable
  # end
  #
  # module Callable
  #   def call(ws : HTTP::WebSocket, cxt : HTTP::Server::Context)
  #     # ... do something
  #   end
  # end
  # ```
  macro ws(path, ws_callable, *, helper = nil)
    # Build the ws handlers
    %ws_handler = HTTP::WebSocketHandler.new do |websocket, context|
      {{ ws_callable }}.call(websocket, context)
      nil
    end

    # Build the proc
    %proc = -> (context : HTTP::Server::Context) {
      %ws_handler.call(context)
      nil
    }

    # Define the action
    %action = ::Orion::Action.new(
      %proc,
      handlers: HANDLERS,
      constraints: CONSTRAINTS
    )

    # Add the route to the tree
    %full_path = ::Orion::DSL.normalize_path(base_path: {{ BASE_PATH }}, path: {{ path }})
    TREE.add(%full_path, %action)

    {% if helper %} # Define the helper
      define_helper(base_path: {{ BASE_PATH }}, path: {{ path }}, spec: {{ helper }})
    {% end %}

    %action.constraints.unshift ::Orion::RequestMethodsConstraint.new("GET")
    %action.constraints.unshift ::Orion::WebSocketConstraint.new
  end

  # Defines a websocket route to a websocket compatible controller and action (short form).
  # You can route to a controller and action by passing the `to` argument in
  # the form of `"MyWebSocket#action"`.
  #
  # ```
  # router WebApp do
  #   ws "/path", to: "Sample#ws"
  # end
  #
  # class SampleController < WebApp::BaseController
  #   def ws
  #     # ... do something
  #   end
  # end
  # ```
  macro ws(path, *, to, helper = nil)
    {% parts = to.split("#") %}
    {% controller = run("../inflector/controllerize.cr", parts[0].id) %}
    {% action = parts[1] %}
    {% raise("`to` must be in the form `controller#action`") unless controller && action && parts.size == 2 %}
    ws({{ path }}, controller: {{ controller.id }}, action: {{ action.id }}, helper: {{ helper }})
  end

  # Defines a match route to a controller and action (long form).
  # You can route to a controller and action by passing the `controller` and
  # `action` arguments, if action is omitted it will default to `match`.
  #
  # ```
  # router WebApp do
  #   ws "/path", controller: SampleController, action: ws
  # end
  #
  # class SampleController < WebApp::BaseController
  #   def ws
  #     # ... do something
  #   end
  # end
  # ```
  macro ws(path, *, action, controller = CONTROLLER, helper = nil)
    ws(
      {{ path }},
      ->(websocket : HTTP::WebSocket, context : HTTP::Server::Context) {
        {{ controller }}.new(context, websocket).{{ action }}
      },
      helper: {{ helper }}
    )
  end

  # Defines a match route with a block.
  #
  # Pass a block as the response and it will be evaluated as a controller
  # 0..2 block parameters are accepted. The block itself will always be evaluated
  # as a controller and have access to all controller methods and macros.
  #
  # ```
  # router MyRouter do
  #   ws "/path" do |websocket, context|
  #     # ... do something
  #   end
  # end
  # ```
  macro ws(path, *, helper = nil, &block)
    {% controller_const = run "../inflector/random_const.cr", "Controller" %}
    struct {{ controller_const }}
      include ::Orion::Controller

      def handle
        {% if block.args.size == 0 %}
          {{ block.body }}
        {% elsif block.args.size == 1 %}
          action_block = ->({{ "#{block.args[0]} : HTTP::WebSocket".id }}){
            {{ block.body }}
          }
          action_block.call(websocket)
        {% elsif block.args.size == 2 %}
          action_block = ->({{ "#{block.args[0]} : HTTP::WebSocket, #{block.args[1]} : HTTP::Request".id }}){
            {{ block.body }}
          }
          action_block.call(websocket, request)
        {% else %}
          {% raise "block must have 0..2 arguments" %}
        {% end %}
      end
    end
    ws({{ path }}, controller: {{ controller_const }}, action: handle, helper: {{ helper }})
  end
end

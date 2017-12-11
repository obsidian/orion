abstract class Orion::Router
  private METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {% for method in METHODS %}
    # Defines a {{method.id}} route.
    #
    # ### Forms:
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
    #   def {{method.downcase.id}}
    #     # ... do something
    #   end
    # end
    #
    # class MyRouter < Orion::Router
    #   {{method.downcase.id}} "/path", to: "MyController#{{method.downcase.id}}"
    # end
    # ```
    #
    # #### Routing to controller and action (long form).
    # You can route to a controller and action by passing the `controller` and
    # `action` arguments, if action is omitted it will default to `{{method.downcase.id}}`.
    #
    # ```
    # class MyController
    #   def new(@context : HTTP::Server::Context)
    #   end
    #
    #   def {{method.downcase.id}}
    #     # ... do something
    #   end
    # end
    #
    # class MyRouter < Orion::Router
    #   {{method.downcase.id}} "/path", controller: MyController, action: {{method.downcase.id}}
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
    # class MyRouter < Orion::Router
    #   {{method.downcase.id}} "/path", Callable
    #   {{method.downcase.id}} "/path", ->(HTTP::Server::Context) {
    #     # ... do something
    #   }
    # end
    # ```
    macro {{method.downcase.id}}(path, callable = nil, *, to = nil, controller = nil, action = nil, name = nil)
      \{% arg_count = 0 }
      \{% arg_count = arg_count + 1 if callable %}
      \{% arg_count = arg_count + 1 if controller %}
      \{% arg_count = arg_count + 1 if to %}

      # Raise arg errors
      \{% if arg_count == 0 %}
        \{% raise "must supply one of: `callable`, `to`, or `controller`" %}
      \{% elsif arg_count > 1 %}
        \{% raise "must supply only one of: `callable`, `to`, or `controller`" %}
      \{% end %}

      # Convert to into `controller` & `action`.
      \{% if to %}
        \{% if !(controller || action) %}
          \{% parts = to.split("#") %}
          \{% controller = parts[0].id %}
          \{% action = parts[1].id %}
          \{% raise("`to` must be in the form `Controller#action`") unless controller && action && parts.size == 2 %}
        \{% end %}
      \{% end %}

      # Build the proc from callable
      \{% if callable %}
        label = \{{callable.id.stringify}}
        proc = -> (context : HTTP::Server::Context) {
          \{{callable}}.call(context)
          nil
        }
      \{% end %}

      # Build the proc from a controller
      \{% if controller %}
        \{% action = action || method.downcase.id %}
        label = [\{{controller.stringify}}, \{{action.stringify}}].join("#")
        proc = -> (context : HTTP::Server::Context) {
          {{BASE_MODULE if BASE_MODULE}}::\{{controller}}.new(context).\{{action}}
          nil
        }
      \{% end %}

      # Add the route
      payload = Payload.new(handlers: HANDLERS, proc: proc, label: label)
      {{method.id}}_TREE.add(normalize_path(\{{path}}), payload)
      (ROUTES[File.join([BASE_PATH, \{{path}}])] ||= {} of Symbol => Payload)[:{{method.id}}] = payload
    end
  {% end %}
end

abstract class Orion::Router
  {% for method in Orion::HTTP_VERBS %}
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
    macro {{method.downcase.id}}(path, callable = nil, *, to = nil, controller = nil, action = {{method.downcase.id}}, helper = nil, constraints = nil, format = nil, accept = nil)
      match(\{{path}}, \{{callable}}, to: \{{to}}, controller: \{{controller}}, action: \{{action}}, helper: \{{helper}}, constraints: \{{constraints}}, format: \{{format}}, accept: \{{accept}}, via: {{method.downcase}})
    end
  {% end %}
end

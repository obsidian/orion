# Request method macros are shorthard ways of constraining a request to a single
# request method. You can read more about the options available to each of these
# macros in the `Orion::DSL::Match`.
module Orion::DSL::RequestMethods
  METHODS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}

  {% for method in METHODS %}
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
    # match "/path", Callable
    # ```
    macro {{ method.downcase.id }}(path, callable, *, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
      match(\{{ path }}, \{{ callable }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end

    # Defines a {{ method.id }} route to a controller and action (short form).
    # You can route to a controller and action by passing the `to` argument in
    # the form of `"#action"`.
    #
    # ```
    # class MyController < BaseController
    #   def match
    #     # ... do something
    #   end
    # end
    #
    # match "/path", to: "My#{{ method.downcase.id }}"
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
    # match "/path", controller: MyController, action: {{ method.downcase.id }}
    # ```
    macro {{ method.downcase.id }}(path, *, action, controller = CONTROLLER, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
      match(\{{ path }}, controller: \{{ controller }}, action: \{{ action }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }})
    end

    # Defines a {{ method.id }} route with a block.
    #
    # You can pass a block. Each block will be evaluated as a controller method
    # and have access to all controller helper methods.
    #
    # ```
    # match "/path" do
    #   # ... do something
    # end
    # ```
    macro {{ method.downcase.id }}(path, *, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
      match(\{{ path }}, via: {{ method.downcase }}, helper: \{{ helper }}, constraints: \{{ constraints }}, format: \{{ format }}, accept: \{{ accept }}, content_type: \{{ content_type }}, type: \{{ type }}) \{{block}}
    end
  {% end %}
end

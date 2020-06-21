# The root macro is a shortcut to making a `get "/"` at the root of you application
# or at the root of a scope.
module Orion::DSL::Root
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
  #   root to: "#action"
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
    get("/", constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }}, helper: "root") {{block}}
  end
end

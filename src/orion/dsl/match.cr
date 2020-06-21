# Catch-all routes using `match`
#
# In some instances, you may just want to redirect all verbs to a particular
# controller and action.
#
# You can use the `match` method and pass it's route and
# any variation of the [Generic Route Arguments](#generic-route-arguments).
#
# ```crystal
# match "404", controller: ErrorsController, action: error_404
# ```
#
# ### Generic route arguments
# There are a variety of ways that you can interact with basic routes. Below are
# some examples and guidelines on the different ways you can interact with the router.
# #### Using `to: String` to target a controller and action
# One of the most common ways we will be creating routes in this guide is to use
# the `to` argument supplied with a controller and action in the form of a string.
# In the example below `users#create` will map to `UsersController.new(cxt : HTTP::Server::Context).create`.
# You can also pass an exact constant name.
#
# ```crystal
# post "users", to: "users#create"
# ```
#
# #### Using `controller: Type` and `action: Method`
# A longer form of the `to` argument strategy above allows us to pass the controller and action
# independently.
#
# ```crystal
# post "users", controller: UsersController, action: create
# ```
#
# #### Using block syntax
# Sometimes, we may want a more link:https://github.com/kemalcr/kemal[kemal] or
# link:http://sinatrarb.com/[sinatra] like approach. To accomplish this, we can
# simply pass a block that will be evaluated as a controller.
#
# ```crystal
# post "users" do
#   "Foo"
# end
# ```
#
# #### Using a `call` able object
# Lastly a second argument can be any
# object that responds to `#call(cxt : HTTP::Server::Context)`.
#
# ```crystal
# post "users", ->(context : HTTP::Server::Context) {
#   context.response.puts "foo"
# }
# ```
module Orion::DSL::Match
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
  # match "/path", Callable
  # ```
  macro match(path, callable, *, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    {% if !format && path.split(".").size > 1 %}
      {% format = path.split(".")[-1] %}
      {% path = path.split(".")[0..-2].join(".") %}
    {% end %}

    # create the action
    %action = ::Orion::Action.new(
      -> (context : HTTP::Server::Context) {
        write_tracker = ::Orion::WriteTracker.new
        output = context.response.output
        context.response.output = ::IO::MultiWriter.new(output, write_tracker, sync_close: true)
        return_value = {{ callable }}.call(context)
        # If no response has been written handle the return value as a response
        if !write_tracker.written
          case return_value
          when String
            context.response.puts return_value
          when IO
            is_invalid = return_value.closed? || return_value == context.response || context.response.output || context.response.@original_output
            IO.copy(return_value, context.response) unless is_invalid
          else
          end
        end
        nil
      },
      handlers: HANDLERS,
      constraints: CONSTRAINTS
    )

    # Add the route to the tree
    TREE.add(
      ::Orion::DSL.normalize_path(base_path: {{ BASE_PATH }}, path: {{ path }}),
      %action
    )

    {% if helper %} # Define the helper
      define_helper(base_path: {{ BASE_PATH }}, path: {{ path }}, spec: {{ helper }})
    {% end %}

    {% if constraints %} # Define the param constraints
      %action.constraints.unshift ::Orion::ParamsConstraint.new({{ constraints }}.to_h)
    {% end %}

    {% if content_type %} # Define the content type constraint
      %action.constraints.unshift ::Orion::ContentTypeConstraint.new({{ content_type }})
    {% end %}

    {% if type %} # Define the content type and accept constraint
      %action.constraints.unshift ::Orion::ContentTypeConstraint.new({{ type }})
      %action.constraints.unshift ::Orion::AcceptConstraint.new({{ type }})
    {% end %}

    {% if format %} # Define the format constraint
      %action.constraints.unshift ::Orion::FormatConstraint.new({{ format }})
    {% end %}

    {% if accept %} # Define the content type constraint
      %action.constraints.unshift ::Orion::AcceptConstraint.new({{ accept }})
    {% end %}

    {% if via != :all && !via.nil? %} # Define the method constraint
      %action.constraints.unshift ::Orion::RequestMethodsConstraint.new({{ via }})
    {% end %}
  end

  # Defines a match route to a controller and action (short form).
  # You can route to a controller and action by passing the `to` argument in
  # the form of `"#action"`.
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
  # match "/path", to: "My#match"
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
  # match "/path", controller: MyController, action: match
  # ```
  macro match(path, *, action, controller = CONTROLLER, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil)
    match({{ path }}, ->(context : HTTP::Server::Context) { {{ controller }}.new(context).{{ action }} }, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end

  # Defines a match route with a block.
  #
  # When given with 0 argument it will yield the block and have access to any method within the BaseController of the application.
  # When given with 1 argument it will yield the block with `HTTP::Server::Context` and have access to any method within the BaseController of the application.
  # When given with 2 arguments it will yield the block with `HTTP::Request` and `HTTP::Server::Response` and have access to any method within the BaseController of the application.
  #
  # ```
  # match "/path" do |context|
  #   # ... do something
  # end
  # ```
  macro match(path, *, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
    {% controller_const = run "./inflector/random_const.cr", "Controller" %}
    struct {{ controller_const }}
      include ::Orion::Controller
      include RouteHelpers

      def handle
        {% if block.args.size == 0 %}
          {{ block.body }}
        {% elsif block.args.size == 1 %}
          action_block = ->({{ "#{block.args[0]} : HTTP::Server::Context".id }}){
            {{ block.body }}
          }
          action_block.call(context)
        {% elsif block.args.size == 2 %}
          action_block = ->({{ "#{block.args[0]} : HTTP::Request, #{block.args[1]} : HTTP::Server::Response".id }}){
            {{ block.body }}
          }
          action_block.call(request, response)
        {% else %}
          {% raise "block must have 0..2 arguments" %}
        {% end %}
      end
    end
    match({{ path }}, controller: {{ controller_const }}, action: handle, via: {{ via }}, helper: {{ helper }}, constraints: {{ constraints }}, format: {{ format }}, accept: {{ accept }}, content_type: {{ content_type }}, type: {{ type }})
  end
end

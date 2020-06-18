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
  # router MyRouter do
  #   match "/path", Callable
  # end
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
      %action.constraints.unshift ::Orion::MethodsConstraint.new({{ via }})
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
  # router MyRouter do
  #   match "/path", to: "My#match"
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
  # When given with 0 argument it will yield the block and have access to any method within the BaseController of the application.
  # When given with 1 argument it will yield the block with `HTTP::Server::Context` and have access to any method within the BaseController of the application.
  # When given with 2 arguments it will yield the block with `HTTP::Request` and `HTTP::Server::Response` and have access to any method within the BaseController of the application.
  #
  # ```
  # router MyRouter do
  #   match "/path" do |context|
  #     # ... do something
  #   end
  # end
  # ```
  macro match(path, *, via = :all, helper = nil, constraints = nil, format = nil, accept = nil, content_type = nil, type = nil, &block)
    {% controller_const = run "./inflector/random_const.cr", "Controller" %}
    struct {{ controller_const }}
      include ::Orion::Controller::Helper

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

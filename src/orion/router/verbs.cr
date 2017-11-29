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
    macro {{method.downcase.id}}(path, callable = nil, *, to = nil, controller = nil, action = {{method.downcase.id}}, helper = nil, constraints = nil, resource = false, format = nil, accept = nil)
      \%full_path = normalize_path(\{{path}}, \{{resource}})
      \{% arg_count = 0 }
      \{% arg_count = arg_count + 1 if callable %}
      \{% arg_count = arg_count + 1 if controller %}
      \{% arg_count = arg_count + 1 if to %}

      \{% if arg_count == 0 %} # Raise arg errors
        \{% raise "must supply one of: `callable`, `to`, or `controller`" %}
      \{% elsif arg_count > 1 %}
        \{% raise "must supply only one of: `callable`, `to`, or `controller`" %}
      \{% end %}

      \{% if to && !controller %} # Convert to into `controller` & `action`.
        \{% parts = to.split("#") %}
        \{% controller = run("./inflector/controllerize.cr", parts[0].id) + "Controller" %}
        \{% action = parts[1].id %}
        \{% raise("`to` must be in the form `controller#action`") unless controller && action && parts.size == 2 %}
      \{% end %}

      \{% if callable %} # Build the proc from callable
        \%label = \{{callable.id}}.is_a?(Proc) ? "proc" : \{{callable.id.stringify}}
        \%proc = -> (context : HTTP::Server::Context) {
          \{{callable}}.call(context)
          nil
        }
      \{% end %}

      \{% if controller %} # Build the proc from a controller
        \{% action = action %}
        \%label = [\{{controller.stringify}}, \{{action.stringify}}].join("#")
        \%proc = -> (context : HTTP::Server::Context) {
          \{{controller}}.new(context).\{{action}}
          nil
        }
      \{% end %}

      # Build the payload
      \%payload = Orion::Payload.new(
        handlers: HANDLERS.dup,
        constraints: CONSTRAINTS.dup,
        proc: \%proc,
        label: \%label
      )

      # Add the route to the correct forest and tree
      FOREST.{{method.downcase.id}}.add(\%full_path, \%payload)

      # Add the route to the route set
      ROUTE_SET.add(method: :{{method.id}}, path: \%full_path, payload: \%payload) unless \{{callable}} == ERR404

      \{% if helper %} # Define the helper
        define_helper(method: {{method}}, path: \{{path}}, spec: \{{helper}})
      \{% end %}

      \{% if constraints %} # Define the param constraints
        \{% constraints_class = run "./inflector/random_const.cr", "ParamConstraints" %}
        # :nodoc:
        class \{{constraints_class}} < ::Orion::Constraint
          def matches?
            \{% for key, value in constraints %}
              return false unless \{{ value }}.match request.query_params[\{{ key.id.stringify }}]?.to_s
            \{% end %}
            true
          end
        end
        \%payload.constraints << \{{constraints_class}}
      \{% end %}

      \{% if format %} # Define the format constraint
        \{% constraints_class = run "./inflector/random_const.cr", "FormatConstraints" %}
        # :nodoc:
        class \{{constraints_class}} < ::Orion::Constraint
          def matches?
            File.extname(request.path).lchop('.') == \{{format}} ||
              File.extname(request.path).lchop('.') =~ \{{format}}
          end
        end
        \%payload.constraints << \{{constraints_class}}
      \{% end %}

      \{% if accept %} # Define the content type constraint
        \{% constraints_class = run "./inflector/random_const.cr", "ContentTypeConstraints" %}
        # :nodoc:
        class \{{constraints_class}} < ::Orion::Constraint
          def matches?
            (request.headers["Accept"]? || "*/*").split(',').map(&.split(';')[0]).any? do |content_type|
              \{% if accept.is_a?(ArrayLiteral) %}
                \{{ accept }}.any? { |m| m == content_type || m =~ content_type }
              \{% else %}
                content_type == \{{ accept }} ||
                  content_type =~ \{{ accept }}
              \{% end %}
            end
          end
        end
        \%payload.constraints << \{{constraints_class}}
      \{% end %}
    end
  {% end %}

  # :nodoc:
  def self.normalize_path(path : String, resource = false)
    base = (shallow_path && resource) ? shallow_path : base_path
    parts = [base, path].map(&.to_s)
    String.build do |str|
      parts.each_with_index do |part, index|
        part.check_no_null_byte

        str << "/" if index > 0

        byte_start = 0
        byte_count = part.bytesize

        if index > 0 && part.starts_with?("/")
          byte_start += 1
          byte_count -= 1
        end

        if index != parts.size - 1 && part.ends_with?("/")
          byte_count -= 1
        end

        str.write part.unsafe_byte_slice(byte_start, byte_count)
      end
    end
  end
end

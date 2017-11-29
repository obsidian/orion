abstract class Orion::Router
  macro scope(**params)
    scope("/", {{**params}}) do
      {{ yield }}
    end
  end

  # Create a group at the specified path.
  macro scope(path = "", *, clear_handlers = false, helper_prefix = nil)
    {% prefixes = PREFIXES + [helper_prefix] if helper_prefix %}
    {% scope_class_name = run "./inflector/random_const.cr", "Scope" %}

    # :nodoc:
    class {{ scope_class_name }} < ::{{@type}}
      # Add the prefixes to the router group if they exist
      {% if helper_prefix %}
        PREFIXES = {{ prefixes }}
      {% end %}

      # Set the base path
      BASE_PATH = File.join(::{{@type}}::BASE_PATH, {{path}})

      # Clear the handlers (if specified)
      HANDLERS.clear if {{clear_handlers}}

      # Yield the block
      {{yield}}

      # Match the rest of the paths
      match "*", ERR404
    end
  end
end

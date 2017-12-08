abstract class Oak::Router
  macro scope(*, clear_handlers = false, helper_prefix = nil)
    {% prefixes = PREFIXES + [helper_prefix] if helper_prefix %}
    {% scope_class_name = run "./inflector/random_const.cr", "Scope" %}

    # :nodoc:
    class {{ scope_class_name }} < ::{{@type}}
      # Add the prefixes to the router group if they exist
      {% if helper_prefix %}
        PREFIXES = {{ prefixes }}
      {% end %}

      # Clear the handlers (if specified)
      HANDLERS.clear if {{clear_handlers}}

      # Yield the block
      {{yield}}
    end
  end

  # Create a group at the specified path.
  macro scope(path, *, clear_handlers = false, helper_prefix = nil)
    scope(clear_handlers: {{clear_handlers}}, helper_prefix: {{helper_prefix}}) do
      # Set the base path
      BASE_PATH = File.join(::{{@type}}::BASE_PATH, {{path}})

      # Yield the block
      {{ yield }}

      # 404 to any unmatched path
      match "*", ->(c : HTTP::Server::Context){
        context.response.respond_with_error(
          message: HTTP.default_status_message_for(404),
          code: 404
        )
      }
    end
  end
end

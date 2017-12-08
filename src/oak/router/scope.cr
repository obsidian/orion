module Oak::Router::Scope
  # Create a scope, optionall nested under a path.
  macro scope(path = nil, helper_prefix = nil)
    {% prefixes = PREFIXES + [helper_prefix] if helper_prefix %}
    {% scope_class_name = run "./inflector/random_const.cr", "Scope" %}

    # :nodoc:
    class {{ scope_class_name }} < ::{{@type}}
      # Set the base path
      {% if path %}
        BASE_PATH = File.join(::{{@type}}::BASE_PATH, {{path}})
      {% end %}

      {% if helper_prefix %}
        PREFIXES = {{ prefixes }}
      {% end %}

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

module Orion::Router::Scope
  # Create a scope, optionall nested under a path.
  macro scope(path = nil, helper_prefix = nil, controller = nil)
    {% prefixes = PREFIXES + [helper_prefix] if helper_prefix %}
    {% scope_class_name = run "./inflector/random_const.cr", "Scope" %}

    # :nodoc:
    class {{ scope_class_name }} < ::{{@type}}
      # Set the controller
      {% if controller %}
        CONTROLLER = {{ controller }}
      {% end %}

      # Set the base path
      {% if path %}
        BASE_PATH = [::{{ @type }}::BASE_PATH.rchop('/'), {{ path }}.lchop('/')].join('/')
        use Orion::ScopeBasePath.new(BASE_PATH)
      {% end %}

      # Setup the helper prefixes
      {% if helper_prefix %}
        PREFIXES = {{ prefixes }}
      {% end %}

      # Yield the block
      {{ yield }}

      # 404 to any unmatched path
      match "*", ::Orion::Handlers::NotFound.new
    end
  end
end

abstract class Orion::Router
  # Create a group at the specified path.
  macro scope(path = "", *, clear_handlers = false, shallow_path = "", helper = nil, concerns = nil)
    {% counter = SCOPE_COUNTER[0] = SCOPE_COUNTER[0] + 1 %}
    {% superclass = @type %}
    {% prefixes = PREFIXES + [helper] if helper %}
    class RouterGroup{{counter}} < ::{{superclass}}
      # Add the prefixes to the router group if they exist
      {% if helper %} PREFIXES = {{ prefixes }} {% end %}

      # Set the base path
      BASE_PATH = File.join(::{{superclass}}::BASE_PATH, {{path}})

      # Set the scope as shallow
      {% if shallow_path %}
        SHALLOW_PATH = File.join(::{{superclass}}::SHALLOW_PATH || "", {{path}})
      {% end %}

      # Clear the handlers (if specified)
      HANDLERS.clear if {{clear_handlers}}

      # Use the concerns
      {% if concerns.is_a? SymbolLiteral %}
        concerns {{concerns}}
      {% elsif concerns %}
        concerns {{*concerns}}
      {% end %}

      # Yield the block
      {{yield}}
    end
  end

  macro shallow(*, clear_handlers = false)
    scope shallow_path: "/", clear_handlers: {{ clear_handlers }} do
      {{yield}}
    end
  end
end

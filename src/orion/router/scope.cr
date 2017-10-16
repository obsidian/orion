abstract class Orion::Router
  # Create a group at the specified path.
  macro scope(path = "", *, clear_handlers = false, shallow_path = "", name = nil, concerns = nil)
    {% counter = SCOPE_COUNTER[0] = SCOPE_COUNTER[0] + 1 %}
    {% superclass = @type %}
    class RouterGroup{{counter}} < ::{{superclass}}
      {% if name %}
        PREFIXES = ::{{@type.superclass}}::PREFIXES.dup
        PREFIXES << singular_name
      {% end %}

      # Set the base path
      BASE_PATH = File.join(::{{superclass}}::BASE_PATH, {{path}})

      # Set the scope as shallow
      {% if shallow_path %}
        SHALLOW_PATH = File.join(::{{superclass}}::SHALLOW_PATH || "", {{path}})
      {% end %}

      # Clear the handlers
      HANDLERS.clear if {{clear_handlers}}

      # Use the concerns
      {% if concerns.is_a? SymbolLiteral %}
        concerns {{concerns}}
      {% elsif concerns %}
        concerns {{*concerns}}
      {% end %}
      {{yield}}
    end
  end

  macro shallow(*, clear_handlers = false)
    scope shallow_path: "/", clear_handlers: {{ clear_handlers }} do
      {{yield}}
    end
  end
end

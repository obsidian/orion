abstract class Orion::Router
  private macro setup_handlers(inherit_concerns)
    {% if inherit_concerns %}
      CONCERNS = ::{{@type.superclass}}::CONCERNS.dup
    {% else %}
      CONCERNS = {} of Symbol => String
    {% end %}
  end

  macro concern(name, &block)
    {% CONCERNS[name] = block.body.stringify %}
  end

  macro concerns(name)
    {{ CONCERNS[name].id }}
  end
end

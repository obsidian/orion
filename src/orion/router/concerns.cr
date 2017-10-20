abstract class Orion::Router
  private macro setup_concerns
    {% if @type.superclass == ::Orion::Router %}
      CONCERNS = {} of Symbol => String
    {% end %}
  end

  macro concern(name, &block)
    {% CONCERNS[name] = block.body.stringify %}
  end

  macro concerns(*names)
    {% for name in names %}
      {{ CONCERNS[name].id }}
    {% end %}
  end
end

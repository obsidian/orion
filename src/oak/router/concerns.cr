module Oak::Router::Concerns
  private macro setup_concerns
    {% if @type.superclass == ::Oak::Router %}
      CONCERNS = {} of Symbol => String
    {% end %}
  end

  macro concern(name, &block)
    {% CONCERNS[name] = block.body.stringify %}
  end

  macro implements(*names)
    {% for name in names %}
      {{ CONCERNS[name].id }}
    {% end %}
  end
end

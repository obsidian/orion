module Orion::DSL::Concerns
  macro concern(name, &block)
    {% CONCERNS[name] = block.body.stringify %}
  end

  macro implements(*names)
    {% for name in names %}
      {{ CONCERNS[name].id }}
    {% end %}
  end
end

abstract class Orion::Router

  # Define a route matching all unassigned verbs.
  macro match(path, callable = nil, *, to = nil, controller = nil, action = nil, name = nil, via = :all)
    {% via = METHODS if via == :all %}
    {% via = [] of StringLiteral unless via %}
    {% via = [via] unless via.is_a? ArrayLiteral %}
    {% via = via.map(&.id.stringify.upcase) }
    {% for method in via.select { |method| METHODS.includes? method } %}
      {{ "Orion::Router.#{method.downcase.id}(#{path}, #{callable}, to: #{to}, controller: #{controller}, action: #{action}, name: #{name})".id }}
    {% end %}
  end
end

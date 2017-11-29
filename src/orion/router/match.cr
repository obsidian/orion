require "radix"

abstract class Orion::Router
  # Define a route matching all unassigned verbs.
  macro match(path, callable = nil, *, to = nil, controller = nil, action = match, helper = nil, constraints = nil, format = nil, accept = nil, via = :all)
    {% via = Orion::HTTP_VERBS if via == :all %}
    {% via = [] of StringLiteral unless via %}
    {% via = [via] unless via.is_a? ArrayLiteral %}
    {% via = via.map(&.id.stringify.upcase) }
    {% for method in via.select { |method| Orion::HTTP_VERBS.includes? method } %}
      begin
        {{method.downcase.id}}({{path}}, {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, helper: {{helper}}, format: {{format}}, accept: {{accept}})
      rescue Radix::Tree::DuplicateError
        # do nothing
      end
    {% end %}
  end
end

abstract class Orion::Router
  # Match all verbs at the specified path, if the verb at this path has already
  # been defined, it will be ignored.
  macro match(path, action, *, via = nil)
    {% via = via || METHODS %}
    {% for method in via.select { |method| METHODS.includes? method.upcase } %}
      begin
        {{method.downcase.id}}({{path}}, {{action}})
      rescue Radix::Tree::DuplicateError
      end
    {% end %}
  end

  # Match all verbs at the specified path, if the verb at this path has already
  # been defined, it will be ignored.
  macro match(path, *, controller, action)
    match(\{{path}}, "\{{controller}}\#{{action}}")
  end
end

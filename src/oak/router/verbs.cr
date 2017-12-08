abstract class Oak::Router
  {% for method in ::HTTP::VERBS %}
    # Defines a {{method}} route
    # for args && params see: `.match`
    macro {{method.downcase.id}}(*args, **params)
      \{% if params.empty? %}
        match(\{{*args}}, action: {{method.downcase.id}}, via: {{method.downcase}})
      \{% else %}
        \{% if params[:action] %}
          match(\{{*args}}, \{{**params}}, via: {{method.downcase}})
        \{% else %}
          match(\{{*args}}, \{{**params}}, action: {{method.downcase.id}}, via: {{method.downcase}})
        \{% end %}
      \{% end %}
    end
  {% end %}
end

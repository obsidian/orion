abstract class Orion::Router
  # Define a `GET /` route at the current path.
  macro root(callable = nil, *, to = nil, controller = nil, action = nil, name = "root")
    get "/", {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, name: {{name}}
  end
end

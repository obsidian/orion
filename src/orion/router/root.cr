abstract class Orion::Router
  # Define a `GET /` route at the current path.
  macro root(callable = nil, *, to = nil, controller = nil, action = nil)
    get "/", {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, name: "root"
  end
end

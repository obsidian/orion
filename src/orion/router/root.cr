abstract class Orion::Router
  # Define a `GET /` route at the current path.
  macro root(*, to)
    get "/", action: {{to}}
  end

  # Define a `GET /` route at the current path.
  macro root(*, controller, action)
    get "/", controller: {{controller}}, action: {{action}}
  end
end

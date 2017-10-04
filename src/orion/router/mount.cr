abstract class Orion::Router
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    match(path: {{at}}, action: {{app}})
  end
end

require "./match"

abstract class Orion::Router
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    Orion::Router.match({{at}}, {{app}})
  end
end

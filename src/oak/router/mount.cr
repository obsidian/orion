require "./match"

abstract class Oak::Router
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    Oak::Router.match({{at}}, {{app}})
  end
end

module Orion::DSL::Mount
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    match({{ at }}, {{ app }})
  end
end

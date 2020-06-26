# You can mount other orion and crystal applications directly within your app.
# This can be useful when separating out concerns between different functional
# areas of your application.
module Orion::DSL::Mount
  # Mount an application at the specified path.
  macro mount(app, *, at = "/")
    match({{ at }}, {{ app }})
  end
end

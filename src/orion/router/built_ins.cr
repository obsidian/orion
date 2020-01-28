module Orion::Router::BuiltIns
  # Mount a directory of static files.
  #
  # router MyRouter do
  #   static dir: "./public", path: "/"
  # end
  # ```
  macro static(*, dir, path = "/")
    scope {{ path }} do
      use Orion::StaticFileHandler.new({{ dir }})
    end
  end
end

module Orion::DSL::Static
  # Mount a directory of static files.
  #
  # router MyRouter do
  #   static dir: "./public", path: "/"
  # end
  # ```
  macro static(*, path = "/", dir)
    scope {{ path }} do
      use Orion::Handlers::StaticFileHandler.new({{ dir }})
    end
  end

  macro static(*, path, string)
    %str : String = {{string}}
    get {{ path }} do |c|
      c.response.puts %str
    end
  end
end

require "uuid"
require "crystar"

# The static macros allows you to bind static content to given path.
# You can use this for strings and/or files that will never change in a given
# release
module Orion::DSL::Static
  # Mount a directory of static files.
  #
  # router MyRouter do
  #   static dir: "./public", path: "/"
  # end
  # ```
  macro static(path = "/", *, dir)
    {% if flag?(:packagestatics) || (flag?(:release) && !flag?(:dontpackagestatics)) %}
      {% dir = dir.gsub(/^\.\//, "") %}
      %dir = File.join(Assets.unpack({{ run "../assets/pack.cr", dir, `date +%s%N` }}), {{ dir }})
    {% else %}
      %dir = {{ dir }}
    {% end %}
    mount ::HTTP::StaticFileHandler.new(%dir, false, false), at: {{ path }}
  end

  macro static(*, path, string)
    %str : String = {{string}}
    get {{ path }}, ->(c : ::Orion::Server::Context){ c.response.puts %str }
  end
end

require "../view"

# This module handles all rendering inside your controllers.
module Orion::Controller::Rendering
  include Orion::View

  # Render json
  macro render(*, json)
    response.content_type = "application/json"
    {{ json }}.to_json(response)
  end

  # Render plain text
  macro render(*, text, content_type = "text/plain")
    response.content_type = "text/plain"
    response.puts({{ text }})
  end

  # :nodoc:
  def __name__
    self.class.name.underscore
  end
end

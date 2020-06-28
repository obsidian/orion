# This module handles all rendering inside your controllers.
module Orion::Controller::Rendering
  @layout_rendered = false

  macro layout(filename)
    private def render_layout(&block): Nil
      if @layout_rendered
        raise ::Orion::DoubleRenderError.new "cannot call render view more than once"
      end
      @layout_rendered = true
      Kilt.embed "src/views/layouts/{{ filename.id }}"
    end
  end

  # Render a view
  macro render(*, view, layout = true)
    {% prefix = run("../inflector/decontrollerize.cr", @type.name).gsub(/^\//, "") %}
    {% view = "src/views/#{prefix}/{{ view.id }}" %}
    {% if layout %}
      render_layout do
        Kilt.embed {{ view }}
        nil
      end
    {% else %}
      Kilt.embed {{ view }}
      nil
    {% end %}
  end

  # Render a view partial
  macro render(*, partial)
    Kilt.embed "src/views/partials/{{ partial.id }}"
    nil
  end

  # Render json
  macro render(*, json)
    response.content_type = "application/json"
    {{ json }}.to_json(response)
    nil
  end

  # Render plain text
  macro render(*, text, content_type = "text/plain")
    response.content_type = "text/plain"
    response.puts({{ text }})
    nil
  end

  def initialize(@context, @websocket = nil)
  end

  protected def render_layout(&block)
    yield
  end

  private def __kilt_io__
    response
  end
end

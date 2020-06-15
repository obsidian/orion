abstract class Orion::Controller::Base
  @layout_rendered = false
  getter context : ::HTTP::Server::Context
  getter! websocket : ::HTTP::WebSocket
  delegate request, response, to: @context

  private macro layout(filename)
    private def render_layout(&block): Nil
      if @layout_rendered
        raise ::Orion::DoubleRenderError.new "cannot call render view more than once"
      end
      @layout_rendered = true
      Kilt.embed "src/views/layouts/{{ filename.id }}"
    end
  end

  private macro render(*, view, layout = true)
    {% if layout %}
      render_layout do
        Kilt.embed "src/views/{{ view.id }}"
        nil
      end
    {% else %}
      Kilt.embed "src/views/{{ view.id }}"
      nil
    {% end %}
  end

  private macro render(*, partial)
    Kilt.embed "src/views/partials/{{ partial.id }}"
    nil
  end

  private macro render(*, json)
    {{ json }}.to_json(response)
    nil
  end

  private macro render(*, text)
    response.puts({{ text }})
    nil
  end

  def initialize(@context, @websocket = nil)
  end

  private def render_layout(&block)
    yield
  end

  private def __kilt_io__
    response
  end
end

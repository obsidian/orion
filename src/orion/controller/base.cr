abstract class Orion::Controller::Base
  getter context : ::HTTP::Server::Context
  delegate request, response, to: @context

  macro set_template_path(path)
    {% TEMPLATE_PATH = path %}
  end

  macro render(template, *, status = 200, content_type = nil)
    response.status = status
    Kilt.embed {{ template }}
  end

  def initialize(@context)
  end

  private def __kilt_io__
    response
  end
end

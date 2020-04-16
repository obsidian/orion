abstract class Orion::Controller::Base
  DEFAULT_LAYOUT = ""

  getter context : ::HTTP::Server::Context
  delegate request, response, to: @context

  macro inherited
    layout "application.ecr"
  end

  macro set_template_path(path)
    {% TEMPLATE_PATH = path %}
  end

  macro layout(filename)
    DEFAULT_LAYOUT = {{ filename }}
  end

  macro render(*, layout = DEFAULT_LAYOUT)
    __kilt_io__ = response
    Kilt.embed "layouts/{{ layout }}"
  end

  macro render(*, json)
    {{ json }}.to_json(response)
  end

  macro render(*, yaml)
    {{ yaml }}.to_yaml(response)
  end

  macro render(*, text)
    response.puts({{ text }})
  end

  def initialize(@context)
  end
end

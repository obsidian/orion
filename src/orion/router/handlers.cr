abstract class Orion::Router
  @handlers = [] of HTTP::Handler

  private macro setup_handlers(inherit_handlers)
    {% if inherit_handlers %}
      HANDLERS = ::{{@type.superclass}}::HANDLERS + ([] of HTTP::Handler)
    {% end %}

    private def self.use(handler : HTTP::Handler)
      HANDLERS << handler
    end
  end

  def use(handler : HTTP::Handler)
    @handlers << handler
  end
end

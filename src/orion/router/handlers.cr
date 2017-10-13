abstract class Orion::Router
  @handlers = ::Orion::HandlerList

  private macro setup_handlers(inherit_handlers)
    {% if inherit_handlers %}
      HANDLERS = ::{{@type.superclass}}::HANDLERS.dup
    {% else %}
      HANDLERS = ::Orion::HandlerList.new
    {% end %}

    private def self.use(handler : HTTP::Handler)
      HANDLERS << handler
    end
  end

  def use(handler : HTTP::Handler)
    @handlers << handler
  end
end

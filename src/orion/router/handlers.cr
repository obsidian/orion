abstract class Orion::Router
  @handlers = ::Orion::HandlerList.new

  private macro setup_handlers
    {% if @type.superclass != ::Orion::Router %}
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

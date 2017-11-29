abstract class Orion::Router
  HANDLERS = ::Orion::HandlerList.new
  @handlers = ::Orion::HandlerList.new

  private macro setup_handlers
    {% if @type.superclass != ::Orion::Router %}
      HANDLERS = ::{{@type.superclass}}::HANDLERS.dup
    {% else %}
      HANDLERS = ::Orion::HandlerList.new
    {% end %}

    def self.use(handler : HTTP::Handler)
      HANDLERS << handler
    end

    def self.use(handler)
      use handler.new
    end

    def self.handlers
      HANDLERS
    end
  end

  def self.handlers
    HANDLERS
  end

  def use(handler : HTTP::Handler)
    @handlers << handler
  end

  def use(handler)
    use handler.new
  end
end

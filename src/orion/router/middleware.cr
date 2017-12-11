module Orion::Router::Middleware
  # :nodoc:
  HANDLERS = [] of HTTP::Handler
  getter handlers = [] of HTTP::Handler

  macro clear_handlers
    handlers.clear
  end

  private macro setup_handlers
    {% if @type.superclass != ::Orion::Router %}
      HANDLERS = ::{{@type.superclass}}::HANDLERS.dup
    {% else %}
      HANDLERS = [] of HTTP::Handler
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

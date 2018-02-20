abstract class Orion::Router
  # :nodoc:
  MIDDLEWARE = [] of Orion::Middleware::Chain::Link
  getter middleware = [] of Orion::Middleware::Chain::Link

  macro clear_middleware
    middleware.clear
  end

  private macro setup_middleware
    {% if @type.superclass != ::Orion::Router %}
      MIDDLEWARE = ::{{@type.superclass}}::MIDDLEWARE.dup
    {% else %}
      MIDDLEWARE = [] of ::Orion::Middleware::Chain::Link
    {% end %}

    def self.use(handler : ::Orion::Middleware::Chain::Link)
      middleware << handler
    end

    def self.use(handler : ::HTTP::Handler.class)
      use handler.new
    end

    def self.use(handler : ::Orion::Middleware.class)
      use handler.new
    end

    def self.use(handler : ::HTTP::Handler)
      MIDDLEWARE << handler
    end

    def self.middleware
      MIDDLEWARE
    end
  end

  def self.middleware
    MIDDLEWARE
  end

  def use(handler : Middleware::Chain::Link)
    @middleware << handler
  end

  def use(handler : HTTP::Handler.class)
    use handler.new
  end

  def use(handler : Middleware.class)
    use handler.new
  end
end

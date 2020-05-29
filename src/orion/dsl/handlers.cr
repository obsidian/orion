module Orion::DSL::Handlers
  # :nodoc:
  HANDLERS = [] of HTTP::Handler

  private macro included
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

  macro clear_handlers
    HANDLERS.clear
  end
end

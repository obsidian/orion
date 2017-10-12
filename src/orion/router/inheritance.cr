require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  BASE_PATH     = "/"
  SHALLOW_PATH = nil
  SCOPE_COUNTER = [0]

  private macro inherited
    setup_handlers({{ @type.superclass != Orion::Router }})

    def self.base_path
      BASE_PATH
    end

    def self.shallow_path
      SHALLOW_PATH
    end

    {% if @type.superclass == Orion::Router %}
      setup_root
    {% end %}
  end
end

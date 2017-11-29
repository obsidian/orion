require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  private macro inherited
    setup_constraints
    setup_handlers
    setup_concerns

    def self.base_path
      BASE_PATH
    end

    def self.shallow_path
      SHALLOW_PATH
    end

    setup_root
  end
end

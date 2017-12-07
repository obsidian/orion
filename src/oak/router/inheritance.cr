require "shell-table"
require "http"

abstract class Oak::Router
  private macro inherited
    setup_constraints
    setup_handlers
    setup_concerns
    setup_root

    def self.base_path
      BASE_PATH
    end
  end
end

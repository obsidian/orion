abstract class Orion::Router
  private macro setup_root
    {% if @type.superclass == Orion::Router %}
      alias ROUTER = self
      BASE_PATH     = "/"
      SHALLOW_PATH  = nil
      ROUTE_SET = Orion::RouteSet.new
      FOREST = Orion::Forest.new
      PREFIXES = [] of String

      # Instance vars
      @route_set = ROUTE_SET
      @handlers = Orion::HandlerList.new
      @forest = FOREST

      def self.routes
        ROUTE_SET
      end
    {% end %}
  end

  # Define a `GET /` route at the current path.
  macro root(callable = nil, *, to = nil, controller = nil, action = nil)
    get "/", {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, name: "root"
  end
end

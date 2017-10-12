abstract class Orion::Router
  private macro setup_root
    BASE_PATH     = "/"
    SHALLOW_PATH  = nil
    ROUTE_SET = Orion::RouteSet.new
    HANDLERS = Orion::HandlerList.new
    FOREST = Orion::Forest.new

    # Instance vars
    @route_set = ROUTE_SET
    @handlers = Orion::HandlerList.new
    @forest = FOREST

    def routes
      ROUTE_SET
    end
  end

  # Define a `GET /` route at the current path.
  macro root(callable = nil, *, to = nil, controller = nil, action = nil)
    get "/", {{callable}}, to: {{to}}, controller: {{controller}}, action: {{action}}, name: "root"
  end
end

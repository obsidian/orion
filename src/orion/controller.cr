require "./cache"
require "./controller/request_helpers"
require "./controller/response_helpers"
require "./controller/rendering"

# The `Orion::Controller` module can be included in any struct or class to add
# the various helpers methods to make constructing your application easier.
module Orion::Controller
  include Rendering
  include RequestHelpers
  include ResponseHelpers
  include CacheHelpers

  # The http context
  getter context : Server::Context

  # The websocket, if the controller was initialized from a `ws` route.
  getter! websocket : ::HTTP::WebSocket

  # :nodoc:
  def initialize(@context, @websocket = nil)
  end
end

require "./controller/base"

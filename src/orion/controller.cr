require "./controller/*"

# The `Orion::Controller` module can be included in any struct or class to add
# the various helpers methods to make constructing your application easier.
module Orion::Controller
  include Rendering
  include RequestHelpers
  include ResponseHelpers

  # The http context
  getter context : ::HTTP::Server::Context

  # The websocket, if the controller was initialized from a `ws` route.
  getter! websocket : ::HTTP::WebSocket

  # Initialize a new controller.
  def initialize(@context, @websocket = nil)
  end
end

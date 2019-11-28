require "http/web_socket"

module Orion::WebSocketControllerHelper
  getter ws : ::HTTP::WebSocket
  getter context : ::HTTP::Server::Context
  delegate request, response, to: @context

  def initialize(@ws, @context)
  end
end

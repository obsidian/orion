require "http/web_socket"

abstract class Orion::Socket::Base
  getter ws : ::HTTP::WebSocket
  getter context : ::HTTP::Server::Context
  delegate request, response, to: @context

  def initialize(@ws, @context)
  end
end

module Orion::ControllerHelper
  getter context : ::HTTP::Server::Context
  delegate request, response, to: @context

  def initialize(@context)
  end
end

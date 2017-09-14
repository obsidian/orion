module Orion::Routeable
  delegate request, response, to: @context

  def initialize(@context : HTTP::Server::Context)
  end
end

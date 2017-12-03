module Orion::Routable
  getter context : Orion::Context
  delegate request, response, to: @context

  def initialize(@context)
  end
end

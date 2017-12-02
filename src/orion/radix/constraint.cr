module Orion::Radix::Constraint
  alias Proc = ::Proc(Orion::Request, , Bool)

  def initialize(@request : Orion::Request)
  end

  abstract def matches?(request : Orion::Request)
end

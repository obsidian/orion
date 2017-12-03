require "./request"

module Orion::Constraint
  alias Proc = ::Proc(Orion::Request, Bool)
  abstract def matches?(request : Orion::Request)
end

require "./constraints/*"

# Include `Orion::Constraint` module and implment it's required methods to
# create custom constraints. You can read more about constraints in
# `Orion::DSL::Constraints`.
module Orion::Constraint
  abstract def matches?(request : HTTP::Request)
end

require "./constraints/*"

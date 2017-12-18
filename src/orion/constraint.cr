module Orion::Constraint
  abstract def matches?(request : HTTP::Request)
end

require "./constraints/*"

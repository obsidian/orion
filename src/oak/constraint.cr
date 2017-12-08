module Oak::Constraint
  abstract def matches?(request : HTTP::Request)
end

require "./constraints/*"

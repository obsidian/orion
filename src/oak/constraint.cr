module Oak::Constraint
  alias Proc = ::Proc(::HTTP::Request, Bool)

  abstract def matches?(request : HTTP::Request)
end

require "./constraints/*"

module Orion::Radix
  abstract struct Constraint
    getter request : HTTP::Request

    def initialize(@request : HTTP::Request)
    end

    abstract def matches? : Bool
  end
end

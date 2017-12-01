module Orion::Radix
  class Constraint
    getter request : HTTP::Request

    def initialize(@request : HTTP::Request)
    end

    def matches?
      true
    end
  end
end

abstract class Orion::Constraint
  getter request : HTTP::Request

  def initialize(@request : HTTP::Request)
  end

  abstract def matches? : Bool
end

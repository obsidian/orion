# :nodoc:
struct Orion::RequestMethodsConstraint
  include Constraint

  @methods : Array(String)

  def initialize(method : String)
    initialize([method])
  end

  def initialize(methods : Array(String))
    @methods = methods.map(&.downcase)
  end

  def matches?(request : ::HTTP::Request)
    return true if request.method.downcase == "*"
    @methods.any?(&.== request.method.downcase)
  end
end

class Orion::HostConstraint
  include Constraint

  def initialize(@constraint : String | Regex)
  end

  def matches?(request : Orion::Request)
    if host = request.host
      matches? host, @constraint
    end
  end

  private def matches?(host : String, string : String)
    host == string
  end

  private def matches?(host : String, regex : Regex)
    host =~ regex
  end
end

# :nodoc:
struct Orion::HostConstraint
  include Constraint

  def initialize(@constraint : String | Regex)
  end

  def matches?(request : ::HTTP::Request)
    if host = request.hostname
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

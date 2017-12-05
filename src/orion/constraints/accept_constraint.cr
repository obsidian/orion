class Orion::AcceptConstraint
  include Radix::Constraint

  def initialize(@accept : String | Regex | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    (request.headers["Accept"]? || "*/*").split(',').map(&.split(';')[0]).any? do |header|
      next true if header = "*/*"
      matches?(header, @accept)
    end
  end

  private def matches?(header : String, string : String)
    header == string
  end

  private def matches?(header : String, regex : Regex)
    header =~ regex
  end

  private def matches?(header : String, strings : Array(String))
    strings.any? do |string|
      matches?(header, string)
    end
  end
end

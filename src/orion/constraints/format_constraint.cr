class Orion::FormatConstraint
  include Constraint

  def initialize(@format : String | Regex | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    extension = File.extname(request.path).lchop(".")
    matches?(extension, @format)
  end

  private def matches?(extension : String, string : String)
    extension == string.lchop(".")
  end

  private def matches?(extension : String, regex : Regex)
    extension =~ regex
  end

  private def matches?(extension : String, strings : Array(String))
    strings.any? do |string|
      matches?(extension, string)
    end
  end
end

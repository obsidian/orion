require "./hash_constraint"

class Orion::HeadersConstraint
  include HashConstraint(String | Regex)

  def matches?(request : Orion::Request)
    @constraints.all? do |key, regex_or_string|
      if header = request.headers[key]?
        matches? header, regex_or_string
      end
    end
  end

  private def matches?(header : String, string : String)
    header == string
  end

  private def matches?(header : String, regex : Regex)
    header =~ regex
  end
end

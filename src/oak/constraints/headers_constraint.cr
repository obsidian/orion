require "./hash_constraint"

struct Oak::HeadersConstraint
  include HashConstraint(String | Regex)

  def matches?(request : ::HTTP::Request)
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
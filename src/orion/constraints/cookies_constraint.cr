require "./hash_constraint"

struct Orion::CookiesConstraint
  include HashConstraint(String | Regex)

  def initialize(constraints)
    initialize constraints.to_hash
  end

  def initialize(@constraints : Hash(String, Regex | String))
  end

  def matches?(request : ::HTTP::Request)
    @constraints.all? do |key, regex_or_string|
      if cookie = request.cookies[key]?
        matches? cookie, regex_or_string
      end
    end
  end

  private def matches?(cookie : HTTP::Cookie, string : String)
    cookie == string
  end

  private def matches?(cookie : HTTP::Cookie, regex : Regex)
    cookie =~ regex
  end
end

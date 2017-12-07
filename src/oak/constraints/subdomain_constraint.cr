struct Oak::SubdomainConstraint
  include Constraint

  def initialize(constraints)
    initialize constraints.to_hash
  end

  def initialize(@constraint : String | Regex)
  end

  def matches?(request : ::HTTP::Request)
    host_parts = request.host.to_s.split('.')
    last_host_part = host_parts.pop
    host_parts.pop unless last_host_part = "localhost"
    subdomain = host_parts.join('.')
    matches? subdomain, @constraint
  end

  private def matches?(subdomain : String, string : String)
    subdomain == string
  end

  private def matches?(subdomain : String, regex : Regex)
    subdomain =~ regex
  end
end

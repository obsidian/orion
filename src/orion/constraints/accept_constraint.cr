# :nodoc:
struct Orion::AcceptConstraint
  include Constraint

  def initialize(@accept : String | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    return false unless request.headers["Accept"]?
    type_for_accept(request).any? do |mime_type|
      matches?(mime_type, @accept)
    end
  end

  private def matches?(mime_type : String, string : String)
    mime_parts = mime_type.split("/")
    match_parts = string.split("/")
    category_matches = mime_parts[0] === match_parts[0] || mime_parts[0] === "*" || match_parts[0] === "*"
    format_matches = mime_parts[1] === match_parts[1] || mime_parts[1] === "*" || match_parts[1] === "*"
    category_matches && format_matches
  end

  private def matches?(mime_type : String, strings : Array(String))
    strings.any? do |string|
      matches?(mime_type, string)
    end
  end

  private def type_for_accept(request : HTTP::Request)
    request.headers["accept"]?.to_s.split(",").map(&.strip).map do |accept|
      accept.split(";").map(&.strip)
    end.sort_by! do |parts|
      part = parts[1..-1].find(&.starts_with? "q=")
      part ? -part.split("=")[-1].strip.to_f : -1
    end.map(&.[0]).map do |content_type|
      content_type
    end
  end
end

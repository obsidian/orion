# :nodoc:
struct Orion::ContentTypeConstraint
  include Constraint

  def initialize(@content_type : String | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    return true unless request.body
    return false unless request.headers["Content-Type"]?
    matches?(type_for_request(request), @content_type)
  end

  private def matches?(mime_type : String, string : String)
    mime_type == string
  end

  private def matches?(mime_type : String, strings : Array(String))
    strings.any? do |string|
      matches?(mime_type, string)
    end
  end

  def type_for_request(request : HTTP::Request)
    request.headers["content-type"]?.to_s.split(';').first
  end
end

# :nodoc:
struct Orion::AcceptConstraint
  include Constraint

  def initialize(@accept : String | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    return false unless request.headers["Accept"]?
    MIME::Types.type_for_accept(request).any? do |mime_type|
      next true if mime_type = "*/*"
      matches?(mime_type, @accept)
    end
  end

  private def matches?(mime_type : String, string : String)
    mime_type == string
  end

  private def matches?(mime_type : String, strings : Array(String))
    strings.any? do |string|
      matches?(mime_type, string)
    end
  end
end

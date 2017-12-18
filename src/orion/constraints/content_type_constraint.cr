# :nodoc:
struct Orion::ContentTypeConstraint
  include Constraint

  def initialize(@content_type : String | Array(String))
  end

  def matches?(request : ::HTTP::Request)
    return true unless request.body
    return false unless request.headers["Content-Type"]?
    MIME::Types.type_for(request).any? do |mime_type|
      matches?(mime_type, @content_type)
    end
  end

  private def matches?(mime_type : MIME::Type, string : String)
    mime_type == string
  end

  private def matches?(mime_type : MIME::Type, strings : Array(String))
    strings.any? do |string|
      matches?(mime_type, string)
    end
  end
end

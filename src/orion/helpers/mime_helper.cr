# :nodoc:
module Orion::MIMEHelper
  extend self

  def request_mime_types(req : HTTP::Request) : Set(String)
    path_type = type_from_path?(req)
    accept_types = types_from_accept(req)
    path_type ? [path_type].to_set + accept_types : accept_types
  end

  def request_extensions(req : HTTP::Request) : Set(String)
    extensions = request_mime_types(req).reduce([] of String) do |exts, mime_type|
      exts.concat MIME.extensions(mime_type)
    end
    (extensions.empty? ? MIME.extensions("text/html") : extensions).to_set
  end

  private def types_from_accept(req : HTTP::Request) : Set(String)
    if (req.headers["Accept"]?)
      req.headers["Accept"]?.to_s.split(",").map do |type|
        parts = type.split(";")
        type = parts.shift
        weight = parts.find(&.starts_with?("q=")).try(&.sub(/^q=/, "").to_f?) || 1.0
        {type, weight}
      end.sort do |l, r|
        r[1] <=> l[1]
      end.map(&.first).to_set
    else
      Set(String).new
    end
  end

  private def type_accepted?(req, type : String) : Bool
    types_from_accept?(req).any? do |req_type|
      req_type, req_subtype = req_type.split("/")
      match_type, match_subtype = type.split("/")
      case {req_type, req_subtype}
      when {"*", "*"}
        true
      when {match_type, "*"}
        true
      when {match_type, match_subtype}
        true
      else
        false
      end
    end
  end

  private def type_from_path?(req : HTTP::Request) : String?
    return if File.extname(req.path).empty?
    mime_type = MIME.from_filename(req.path.not_nil!)
    mime_type.to_s if mime_type
  rescue
    nil
  end
end

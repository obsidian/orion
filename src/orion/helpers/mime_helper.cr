module MIMEHelper
  private def request_mime_type(req : HTTP::Request)
    type_from_accept?(req) || type_from_path?(req) || "text/html"
  end

  private def type_from_accept?(req : HTTP::Request)
    req.headers["Accept"]?
  end

  private def type_from_path?(req : HTTP::Request)
    return if File.extname(req.path).empty?
    mime_type = MIME.from_filename(req.path.not_nil!)
    mime_type.to_s if mime_type
  rescue
    nil
  end

  private def request_extensions(req : HTTP::Request)
    MIME.extensions(request_mime_type(req))
  end
end

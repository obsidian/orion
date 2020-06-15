module MIMEHelper
  private def request_mime_types(req : HTTP::Request)
    types_from_accept?(req) || [type_from_path?(req)].compact
  end

  private def types_from_accept?(req : HTTP::Request)
    if (req.headers["Accept"]?)
      req.headers["Accept"]?.to_s.split(",")
    end
  end

  private def type_from_path?(req : HTTP::Request)
    return if File.extname(req.path).empty?
    mime_type = MIME.from_filename(req.path.not_nil!)
    mime_type.to_s if mime_type
  rescue
    nil
  end

  private def request_extensions(req : HTTP::Request)
    extensions = request_mime_types(req).reduce([] of String) do |exts, mime_type|
      exts.concat MIME.extensions(mime_type)
    end
    extensions.empty? ? MIME.extensions("text/html") : extensions
  end
end

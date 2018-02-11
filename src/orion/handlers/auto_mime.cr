# :nodoc:
class Orion::Handlers::AutoMime
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    if !cxt.request.headers["Accept"]? && (mime_type = type_from_path?(cxt.request))
      cxt.request.headers["Accept"] = mime_type
    end
    call_next cxt
  end

  private def type_from_path?(req : HTTP::Request)
    return if File.extname(req.path).empty?
    mime_type = MIME::Types.type_for(req.path).first?
    mime_type.to_s if mime_type
  end
end

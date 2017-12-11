# :nodoc:
class Orion::Handlers::AutoMime
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    if !cxt.request.headers["Accept"]? && !File.extname(cxt.request.path).empty? && (mime_type = MIME::Types.type_for(cxt.request.path).first?)
      cxt.request.headers["Accept"] = mime_type.to_s
    end
    call_next cxt
  end
end

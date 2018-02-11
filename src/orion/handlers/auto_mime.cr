# :nodoc:
class Orion::Handlers::AutoMime
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    cxt.request.headers["Accept"] ||= type_from_path?(cxt.request)
    call_next cxt
  end

  private def type_from_path?(req : HTTP::Request)
    return if File.extname(cxt.request.path).empty?
    mime_type = MIME::Types.type_for(cxt.request.path).first?
    mime_type.to_s if mime_type
  end
end

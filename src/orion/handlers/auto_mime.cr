# :nodoc:
class Orion::Handlers::AutoMime
  include HTTP::Handler
  include MIMEHelper

  def call(cxt : HTTP::Server::Context)
    cxt.request.headers["Accept"] ||= type_from_path?(cxt.request) || "*/*"
    call_next(cxt)
    if (content_type = request_mime_types(cxt.request).first?)
      cxt.response.headers["Content-Type"] ||= content_type
    end
  end
end

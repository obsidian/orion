# :nodoc:
class Orion::Handlers::AutoMime
  include HTTP::Handler
  include MIMEHelper

  def call(cxt : HTTP::Server::Context)
    cxt.request.headers["Accept"] ||= request_mime_type(cxt.request)
    call_next cxt
  end
end

# :nodoc:
class Orion::Handlers::Meta
  include HTTP::Handler
  include MIMEHelper

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    if (content_type = request_mime_types(cxt.request).first?)
      cxt.response.headers["Content-Type"] ||= content_type
    end
  end
end

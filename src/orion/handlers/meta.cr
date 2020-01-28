# :nodoc:
class Orion::Handlers::Meta
  include HTTP::Handler
  include MIMEHelper

  def call(cxt : HTTP::Server::Context)
    call_next cxt
    cxt.response.headers["Content-Type"] ||= request_mime_type(cxt.request)
  end
end

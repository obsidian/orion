class Orion::Handlers::NotFound
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    cxt.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    )
  end
end

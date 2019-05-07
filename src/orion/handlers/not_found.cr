class Orion::Handlers::NotFound
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    cxt.response.respond_with_error(
      message: HTTP::Status.new(404).description,
      code: 404
    )
  end
end

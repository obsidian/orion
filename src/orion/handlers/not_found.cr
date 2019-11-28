class Orion::Handlers::NotFound
  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    cxt.response.respond_with_status(:not_found)
  end
end

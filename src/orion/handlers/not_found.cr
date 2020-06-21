class Orion::Handlers::NotFound
  STATUS = HTTP::Status::NOT_FOUND

  include HTTP::Handler

  def call(cxt : HTTP::Server::Context)
    response = cxt.response
    response.content_type = "text/plain"
    response.status = STATUS
    raise RoutingError.new("No route matches [#{cxt.request.method}] \"#{cxt.request.path}\"")
  end
end

class Orion::Radix::Tree
  include Orion::Handler

  NOT_FOUND = ->(context : HTTP::Server::Context) {
    context.response.respond_with_error(
      message: HTTP.default_status_message_for(404),
      code: 404
    )
    context.response.close
    nil
  }

  @root = Node.new
  delegate add, viz, to: @root

  def call(context : ::HTTP::Server::Context)
    (find(context.request) || NOT_FOUND).call(context)
  end

  def find(request : ::HTTP::Request)
    path = request.path
    @root.find(path.rchop(File.extname(path)), Result.new(request.path_params), &.matches_constraints?(request))
  end

  def find(path : String, host = "example.com")
    headers = HTTP::Headers.new
    headers["HOST"] = host
    find ::HTTP::Request.new("*", path, headers)
  end
end

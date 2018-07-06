class Orion::Handlers::RouteFinder
  include HTTP::Handler

  def initialize(@tree : Orion::Router::Tree)
  end

  def call(cxt : HTTP::Server::Context)
    leaf = nil
    path = cxt.request.path
    @tree.search(path.rchop(File.extname(path))) do |result|
      unless leaf
        cxt.request.path_params = result.params
        leaf = result.payloads.find &.matches_constraints? cxt.request
        leaf.try &.call(cxt)
      end
    end

    # lastly return with 404
    call_next cxt unless leaf
  end
end

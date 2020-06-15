class Orion::Handlers::RouteFinder
  include HTTP::Handler

  @tree : Orion::DSL::Tree

  def initialize(@tree : Orion::DSL::Tree)
  end

  def call(cxt : HTTP::Server::Context)
    action = nil
    path = cxt.request.path
    @tree.search(path.rchop(File.extname(path))) do |result|
      unless action
        cxt.request.path_params = result.params
        cxt.request.format = File.extname(path)
        action = result.payloads.find &.matches_constraints? cxt.request
        action.try &.call(cxt)
      end
    end

    # lastly return with 404
    call_next cxt unless action
  end
end

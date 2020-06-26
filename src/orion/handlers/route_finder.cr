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
        action = result.payloads.find &.matches_constraints? cxt.request
        action.try &.call(cxt)
      end
    end

    unless action
      raise RoutingError.new("No route matches [#{cxt.request.method}] \"#{cxt.request.path}\"")
    end
  end
end

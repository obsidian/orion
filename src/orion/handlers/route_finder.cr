class Orion::Handlers::RouteFinder
  include Handler

  @tree : DSL::Tree
  @strip_extension : Bool

  def initialize(@tree : DSL::Tree, *, @strip_extension = false)
  end

  def call(cxt : Server::Context)
    action = nil
    path = cxt.request.path
    @tree.search(@strip_extension ? path.rchop(File.extname(path)) : path) do |result|
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

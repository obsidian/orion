struct Oak::Tree::Result
  @matched = {} of HTTP::Request => Leaf
  @nodes = [] of Branch
  getter params = {} of String => String
  getter leaves = [] of Leaf

  def key
    String.build do |io|
      @nodes.each do |node|
        io << node.key
      end
    end
  end

  def track(node : Branch)
    @nodes << node
  end

  def use(node : Branch)
    track node
    @leaves.replace node.leaves
    self
  end

  def call(context : HTTP::Server::Context)
    context.request.path_params = params
    matched_payload(context.request).not_nil!.call(context)
  end

  def matches_constraints?(request : HTTP::Request)
    request.path_params = params
    !!matched_payload(request)
  end

  private def matched_payload(request : HTTP::Request)
    return leaves.find(&.matches_constraints? request)
    return @matched[request] if @matched[request]?
    if matched = leaves.find(&.matches_constraints? request)
      @matched[request] = matched
    end
  end
end

struct Orion::Radix::Result
  @matched = {} of HTTP::Request => Payload
  @nodes = [] of Node
  getter params = {} of String => String
  getter payloads = [] of Payload

  def key
    String.build do |io|
      @nodes.each do |node|
        io << node.key
      end
    end
  end

  def track(node : Node)
    @nodes << node
  end

  def use(node : Node)
    track node
    @payloads.replace node.payloads
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
    return @matched[request] if @matched[request]?
    if matched = payloads.find(&.matches_constraints? request)
      @matched[request] = matched
    end
  end
end

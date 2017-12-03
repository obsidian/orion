class Orion::Radix::Result
  include HTTP::Handler

  @key : String?
  @nodes = [] of Node
  getter params = {} of String => String
  getter payloads = [] of Payload

  def initialize(@params = {} of String => String)
  end

  def key
    @key ||= String.build do |io|
      @nodes.each do |node|
        io << node.key
      end
    end
  end

  def track(node : Node)
    @key = nil
    @nodes << node
  end

  def use(node : Node)
    track node
    @payloads = node.payloads
    self
  end

  def call(context : ::HTTP::Server::Context)
    payloads.find(&.matches_constraints? context.request).not_nil!.call(context)
  end

  def call(context : HTTP::Server::Context)
    payloads.first.call(context)
  end

end

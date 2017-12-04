struct Orion::Radix::Node::Context
  getter children = [] of Node
  getter payloads = [] of Payload

  def initialize
  end

  def initialize(node : Node)
    children << node
  end

  def payloads?
    !@payloads.empty?
  end
end

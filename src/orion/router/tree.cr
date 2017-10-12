require "radix"

abstract class Orion::Router
  alias Tree = Radix::Tree(Payload)
end

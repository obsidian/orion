# :nodoc:
macro exception(const)
  # :nodoc:
  class Orion::{{ const }} < Exception; end
end

exception DoubleRenderError

# :nodoc:
class Orion::ParametersMissing < Exception
  def initialize(keys : Array(String))
    initialize("Missing parameters: #{keys.join(", ")}")
  end
end

macro exception(const)
  class Orion::{{ const }} < Exception; end
end

exception DoubleRenderError

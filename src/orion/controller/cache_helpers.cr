module Orion::Controller::CacheHelpers
  def cache
    @context.config.cache
  end
end

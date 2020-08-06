require "../cache"
require "./*"

class Orion::View::Renderer
  include Controller::RequestHelpers
  include Registry
  include AssetTagHelpers
  include PartialHelpers
  include CacheHelpers

  getter config : Orion::Config::ReadOnly
  getter controller_name : String
  getter request : Orion::Server::Request
  getter __kilt_io__ : IO

  def initialize(controller : Orion::Controller)
    @__kilt_io__ = IO::MultiWriter.new controller.response
    @request = controller.request
    @config = controller.context.config
    @controller_name = controller.__name__
  end
end

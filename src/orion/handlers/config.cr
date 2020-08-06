# :nodoc:
class Orion::Handlers::Config
  include Handler
  @config : Orion::Config

  def initialize(@config : Orion::Config)
  end

  def call(cxt : Server::Context)
    cxt.config = @config.readonly
    call_next cxt
  end
end

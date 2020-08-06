class Orion::Handlers::ScopeBasePath
  include Handler

  def initialize(@base_path : String)
  end

  def call(cxt : Orion::Server::Context)
    cxt.request.base_path = @base_path
    call_next cxt
  end
end

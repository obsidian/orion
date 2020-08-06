# :nodoc:
class Orion::Handlers::AutoClose
  include Handler

  def call(cxt : Server::Context)
    call_next cxt
    cxt.response.close unless cxt.response.closed?
  end
end

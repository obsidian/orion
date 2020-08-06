class Orion::Handlers::ResetPath
  include Handler

  def call(cxt : Server::Context)
    cxt.request.path = cxt.request.path.sub(/^#{cxt.request.base_path}/, "")
    call_next(cxt)
    cxt.request.reset_path!
  end
end

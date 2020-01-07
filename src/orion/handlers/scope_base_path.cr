class Orion::ScopeBasePath
  include HTTP::Handler

  def initialize(@base_path : String)
  end

  def call(cxt : HTTP::Server::Context)
    cxt.request.base_path = @base_path
    call_next cxt
  end
end

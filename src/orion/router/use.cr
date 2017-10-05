abstract class Orion::Router
  @handlers = [] of HTTP::Handler

  def use(handler : HTTP::Handler)
    @handlers << handler
  end
end

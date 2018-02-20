struct Orion::Middleware::Chain
  alias Link = Middleware | HTTP::Handler | HTTP::Handler::Proc

  @links: Array(Link) = [] of Link

  def initialize(links, last_link : HTTP::Handler::Proc? = nil)
    links.each do |link|
      @links << (link.is_a?(HTTP::Handler) ? link.dup : link)
    end
    @links << last_link if last_link
  end

  def call(c : HTTP::Server::Context) : Nil
    call_link @links.shift?, c
  end

  def call_link(middleware : Middleware, c : HTTP::Server::Context)
    middleware.call(c) do |c|
      self.call(c)
    end
  end

  def call_link(proc : HTTP::Handler::Proc, c : HTTP::Server::Context)
    proc.call(c)
  end

  def call_link(handler : HTTP::Handler, c)
    handler.next = ->(c : HTTP::Server::Context){ self.call(c) }
    handler.call(c)
  end

  def call_link(proc : Nil, c : HTTP::Server::Context)
  end

  def to_proc
    -> (c : HTTP::Server::Context) { self.class.new(@links).call(c) }
  end
end

require "digest"

struct Orion::Pipeline
  CACHE         = {} of String => Pipeline
  ROUTE_HANDLER = ->(c : HTTP::Server::Context) { c.request.action.try &.invoke(c) }

  @pipeline : ::HTTP::Handler | ::HTTP::Handler::HandlerProc
  @cache_key : String

  def self.new(handlers)
    key = cache_key(handlers)
    CACHE[key]? || Pipeline.new(handlers, key)
  end

  private def self.cache_key(handlers : Array(::HTTP::Handler))
    Digest::MD5.hexdigest do |ctx|
      handlers.each do |handler|
        ctx.update handler.object_id.to_s
      end
    end
  end

  def initialize(handlers : Array(::HTTP::Handler), @cache_key)
    handlers = handlers.map(&.dup.as(::HTTP::Handler))
    @pipeline = handlers.empty? ? ROUTE_HANDLER : ::HTTP::Server.build_middleware(handlers, ROUTE_HANDLER)
    CACHE[cache_key] = self
  end

  def call(c : ::HTTP::Server::Context) : Nil
    @pipeline.call(c)
  end
end

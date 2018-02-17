require "digest"

class Orion::Pipeline
  include ::HTTP::Handler

  CACHE = {} of String => Pipeline

  @pipeline : ::HTTP::Handler?

  def self.new(handlers)
    key = cache_key(handlers)
    CACHE[key]? || Pipeline.new(handlers, key)
  end

  def self.build(handlers, proc)
    new(handlers).build(proc)
  end

  private def self.cache_key(handlers : Array(::HTTP::Handler))
    Digest::MD5.hexdigest do |ctx|
      handlers.each do |handler|
        ctx.update handler.object_id.to_s
      end
    end
  end

  def initialize(handlers : Array(::HTTP::Handler), @cache_key : String)
    @pipeline = unless handlers.empty?
      ::HTTP::Server.build_middleware(handlers.map(&.dup.as(::HTTP::Handler)), ->(c : ::HTTP::Server::Context) { puts c.response.status_code })
    end
    CACHE[cache_key] = self
  end

  def build(proc : ::HTTP::Handler::Proc)
    ::HTTP::Server.build_middleware([dup], proc)
  end

  def call(c : ::HTTP::Server::Context, &next) : Nil
    @pipeline.try &.call(c)
    next.call(c)
  end

end

require "http"

module Orion::Middleware
  # Rate limiting middleware
  # Prevents abuse by limiting requests per time window
  #
  # Usage:
  #   use Orion::Middleware::RateLimiter.new(
  #     requests: 100,
  #     period: 1.minute,
  #     strategy: :ip  # or :session, :custom
  #   )
  #
  # Custom identifier:
  #   use Orion::Middleware::RateLimiter.new(requests: 100, period: 1.minute) do |context|
  #     context.session[:user_id]? || context.request.remote_address.to_s
  #   end
  class RateLimiter
    include HTTP::Handler

    alias IdentifierProc = Proc(HTTP::Server::Context, String)

    property requests : Int32
    property period : Time::Span
    property identifier : IdentifierProc

    @@buckets = {} of String => Bucket

    def initialize(
      @requests : Int32,
      @period : Time::Span,
      strategy : Symbol = :ip,
      @identifier : IdentifierProc? = nil
    )
      # Set default identifier based on strategy
      unless @identifier
        @identifier = case strategy
                      when :ip
                        ->(ctx : HTTP::Server::Context) {
                          ctx.request.remote_address.try(&.to_s) || "unknown"
                        }
                      when :session
                        ->(ctx : HTTP::Server::Context) {
                          if ctx.is_a?(Orion::Server::Context)
                            ctx.session[:user_id]? || "anonymous"
                          else
                            "anonymous"
                          end
                        }
                      else
                        raise "Unknown strategy: #{strategy}"
                      end
      end

      # Start cleanup task
      spawn { cleanup_loop }
    end

    def initialize(
      @requests : Int32,
      @period : Time::Span,
      &block : IdentifierProc
    )
      @identifier = block
      spawn { cleanup_loop }
    end

    def call(context : HTTP::Server::Context)
      # Get client identifier
      client_id = @identifier.call(context)
      bucket = get_or_create_bucket(client_id)

      # Check rate limit
      if bucket.allow?
        # Add rate limit headers
        add_rate_limit_headers(context.response, bucket)
        call_next(context)
      else
        # Rate limit exceeded
        context.response.status_code = 429
        context.response.content_type = "application/json"
        add_rate_limit_headers(context.response, bucket)
        context.response.print({
          error:       "Rate limit exceeded",
          retry_after: bucket.reset_in.total_seconds.to_i,
        }.to_json)
      end
    end

    private def get_or_create_bucket(client_id : String) : Bucket
      @@buckets[client_id] ||= Bucket.new(@requests, @period)
    end

    private def add_rate_limit_headers(response : HTTP::Server::Response, bucket : Bucket)
      response.headers["X-RateLimit-Limit"] = @requests.to_s
      response.headers["X-RateLimit-Remaining"] = bucket.remaining.to_s
      response.headers["X-RateLimit-Reset"] = bucket.reset_at.to_unix.to_s
    end

    private def cleanup_loop
      loop do
        sleep @period
        cleanup_expired_buckets
      end
    end

    private def cleanup_expired_buckets
      now = Time.utc
      @@buckets.reject! do |_, bucket|
        bucket.reset_at < now
      end
    end

    # Token bucket implementation
    class Bucket
      property tokens : Int32
      property capacity : Int32
      property period : Time::Span
      property reset_at : Time

      def initialize(@capacity : Int32, @period : Time::Span)
        @tokens = @capacity
        @reset_at = Time.utc + @period
      end

      def allow? : Bool
        refill_if_needed

        if @tokens > 0
          @tokens -= 1
          true
        else
          false
        end
      end

      def remaining : Int32
        refill_if_needed
        @tokens
      end

      def reset_in : Time::Span
        (@reset_at - Time.utc).abs
      end

      private def refill_if_needed
        if Time.utc >= @reset_at
          @tokens = @capacity
          @reset_at = Time.utc + @period
        end
      end
    end
  end
end

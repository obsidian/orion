require "uuid"

class Orion::Handlers::Logger
  include Handler

  def initialize(@log = Log.for("http.server"))
  end

  def call(context)
    Log.with_context do
      start = Time.monotonic
      request_id = UUID.random.to_s
      Log.context.set(operation: {id: request_id})
      begin
        call_next(context)
      ensure
        elapsed = Time.monotonic - start
        elapsed_text = elapsed_text(elapsed)

        req = context.request
        res = context.response

        addr =
          {% begin %}
            case remote_address = req.remote_address
            when nil
              "-"
            {% unless flag?(:win32) %}
            when Socket::IPAddress
              remote_address.address
            {% end %}
            else
              remote_address
            end
            {% end %}
        @log.with_context do
          @log.context.set(
            http_request: {
              "requestMethod" => req.method,
              "requestUrl"    => URI.new(host: req.headers["Host"], path: req.resource, query: req.query_params).to_s,
              "userAgent"     => req.headers["User-Agent"],
              "remoteIp"      => req.remote_address.as?(Socket::IPAddress).try(&.address),
              "status"        => res.status_code,
              "latency"       => "#{elapsed.total_seconds}s",
            },
          )
          @log.info { "#{addr} - #{req.method} #{req.resource} #{req.version} - #{res.status_code} (#{elapsed_text})" }
        end
      end
    end
  end

  private def elapsed_text(elapsed)
    minutes = elapsed.total_minutes
    return "#{minutes.round(2)}m" if minutes >= 1

    "#{elapsed.total_seconds.humanize(precision: 2, significant: false)}s"
  end
end

require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  include HTTP::Handler

  def self.route_table
    new.route_table
  end

  @handlers = [] of HTTP::Handler
  @routes = {} of String => Hash(Symbol, Payload)

  abstract def get_tree(method : String)

  def initialize(autoclose = true, handlers = [] of HTTP::Handler)
    use Handlers::AutoClose.new if autoclose
    handlers.map { |handler| use handler }
  end

  def use(handler : HTTP::Handler)
    @handlers << handler
  end

  def call(context) : Nil
    # Gather the details
    request = context.request
    method = request.method.downcase
    path = request.path

    # Find the route or 404
    result = get_tree(method).find(path)
    return context.response.respond_with_error(message = "Not Found", code = 404) unless result.found?

    # Build the middleware and call
    handlers = [Handlers::ParamsInjector.new(result.params)] + @handlers + result.payload.handlers
    HTTP::Server.build_middleware(handlers, result.payload.action).call(context)
  end

  def route_table
    rows = @routes.each_with_object([] of Array(String)) do |(path, methods), rows|
      methods.each do |method, payload|
        color = case method
                when :GET, :HEAD
                  :light_green
                when :PUT, :PATCH
                  :light_yellow
                when :DELETE
                  :light_red
                else
                  :cyan
                end
        method_string = method.to_s.colorize(color).to_s
        rows << [method_string, path, payload.label]
      end
    end
    ShellTable.new(
      labels: %w{METHOD PATH ACTION},
      label_color: :white,
      rows: rows
    )
  end
end

require "./router/*"
require "./handlers/*"

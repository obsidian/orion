require "http"

HTTP::Server.new(port: ENV["PORT"].to_i, host: "0.0.0.0") do |c|
end.listen

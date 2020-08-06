require "http"

class Orion::Server::RequestProcessor < HTTP::Server::RequestProcessor
  include HTTP
  # Some magic to ensure support for all versions of crystal
  {{ HTTP::Server::RequestProcessor.methods.map(&.id.gsub(/HTTP::(Server::)?(Request|Response|Context)/, "::Orion::Server::\\2")).join("\n").id }}
end

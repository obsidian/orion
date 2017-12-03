require "http"
require "shell-table"

module Orion
  HTTP_VERBS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}
  # alias Request = HTTP::Request
  # alias Context = HTTP::Server::Context
  # alias Response = HTTP::Server::Context
  {{ run "./parse_version.cr" }}
end

macro router(name)
  class {{ name }} < ::Orion::Router
    scope "/" do
      {{yield}}
    end
  end
end

require "./orion/*"

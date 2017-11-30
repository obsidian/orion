require "http"
require "shell-table"

module Orion
  HTTP_VERBS = %w{GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH}
  {{ run "./parse_version.cr" }}
end

macro router(name)
  class {{ name }} < ::Orion::Router
    {{yield}}
  end
end

require "./orion/*"

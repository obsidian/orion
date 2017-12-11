require "shell-table"
require "http"
require "oak"
require "./orion/*"

module Orion
  {{ run "./parse_version.cr" }}
end

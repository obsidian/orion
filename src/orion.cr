require "oak"
require "kilt"
require "./http"
require "./macro"
require "./orion/*"

module Orion
  # :nodoc:
  FLAGS = {} of String => Bool

  {{ run "./parse_version.cr" }}
end

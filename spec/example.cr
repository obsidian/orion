require "../src/orion"
require "./fixtures"

puts "Listening on 3000"
HTTP::Server.new(3000, SampleRouter.new).listen

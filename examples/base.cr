require "../src/orion"
include Orion::DSL

root do |c|
  context.response.puts "ok"
end

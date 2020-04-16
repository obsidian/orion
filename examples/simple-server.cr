require "../src/orion"

router MyApplication do
  use HTTP::LogHandler.new

  get "empty" do |context|
    context.response.puts "e"
  end

  get "/*", ->(context : Context) do
    context.response.puts "reviews"
  end

  get "/resources/js/*", ->(context : Context) do
    context.response.puts "somejs"
  end

  get "/robots.txt", ->(context : Context) do
    context.response.puts "robots"
  end
end

puts MyApplication.visualize

MyApplication.start(workers: System.cpu_count)

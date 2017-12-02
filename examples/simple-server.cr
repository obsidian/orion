require "../src/orion"

router MyApplication do
  use HTTP::LogHandler.new

  get "/*", ->(context : Context) do
    context.response.puts "reviews"
  end

  get "/resources/js/*" , ->(context : Context) do
    context.response.puts "somejs"
  end

  get "/robots.txt", ->(context : Context) do
    context.response.puts "robots"
  end
end

MyApplication.listen(port: 3000)

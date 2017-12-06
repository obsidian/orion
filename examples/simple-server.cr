require "../src/orion"

router MyApplication do
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

MyApplication.listen(port: 3000)

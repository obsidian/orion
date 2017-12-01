require "../src/orion"

router MyApplication do
  root ->(context : Context) do
    context.response.puts "Hello world"
  end
end

MyApplication.listen(port: 3000)

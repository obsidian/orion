require "../src/app"

root do
  raise "Oops"
end

scope "/foo" do
  scope "/bar" do
    root do
      "Hello Foo"
    end
  end
end

get "/users", helper: "users" do
  render text: users_path
end

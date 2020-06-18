require "../src/app"

scope "/foo" do
  scope "/bar" do
    root do
      "Hello Foo"
    end
  end
end

get "/users", helper: "users" do
  users_path
end

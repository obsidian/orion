require "../src/app"

root do
  root_path
end

get "/users", helper: "users" do
  users_path
end

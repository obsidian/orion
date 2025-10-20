require "../src/orion"

# Demo: DSL improvements for better developer experience

class User
  property id : Int64
  property name : String
  property email : String

  def initialize(@id, @name, @email)
  end

  def self.find?(id : String) : User?
    return nil if id == "999"
    new(id.to_i64, "User #{id}", "user#{id}@example.com")
  end

  def self.all : Array(User)
    (1..10).map { |i| new(i.to_i64, "User #{i}", "user#{i}@example.com") }.to_a
  end

  def to_h
    {
      id: @id,
      name: @name,
      email: @email
    }
  end
end

router DSLDemo do
  # ===== STATUS HELPERS DEMO =====

  get "/status/ok" do
    ok! "Everything is fine"
  end

  get "/status/not-found" do
    not_found! "Page doesn't exist"
  end

  get "/status/unauthorized" do
    unauthorized! json: {error: "Invalid token", code: "auth_failed"}
  end

  get "/status/created" do
    created! json: {id: 123, message: "User created"}, location: "/users/123"
  end

  get "/status/no-content" do
    no_content!
  end

  get "/status/head" do
    head :ok  # 200 with no body
  end

  # ===== JSON HELPERS DEMO =====

  get "/json/simple" do
    json({message: "Hello JSON"})
  end

  get "/json/users" do
    users = User.all
    json({users: users.map(&.to_h)})
  end

  get "/json/created" do
    user = {id: 1, name: "New User"}
    json_created(user, location: "/users/1")
  end

  get "/json/error" do
    json_bad_request({error: "Invalid input", field: "email"})
  end

  # ===== PARAM HELPERS DEMO =====

  get "/params/basic" do
    # Access query params easily
    name = params["name"]? || "Guest"
    age = params["age"]? || "unknown"

    json({greeting: "Hello #{name}, age #{age}"})
  end

  get "/params/path/:user_id/posts/:post_id" do
    # Params merges path_params automatically
    user_id = params["user_id"]
    post_id = params["post_id"]

    json({
      user_id: user_id,
      post_id: post_id,
      message: "Accessing user #{user_id}'s post #{post_id}"
    })
  end

  post "/params/strong" do
    # Strong parameters (simplified version)
    permitted = params.permit("name", "email", "age")

    json({
      message: "Received permitted params",
      params: permitted
    })
  end

  # ===== COMBINED EXAMPLES =====

  get "/api/users" do
    users = User.all
    json({
      users: users.map(&.to_h),
      count: users.size
    })
  end

  get "/api/users/:id" do
    user = User.find?(params["id"])

    unless user
      not_found! json: {error: "User not found", id: params["id"]}
      next  # Stop processing
    end

    json(user.to_h)
  end

  post "/api/users" do
    # Simulate creation
    name = params["name"]? || "Unknown"
    email = params["email"]? || "no-email"

    if name == "Unknown"
      bad_request! json: {error: "Name is required"}
      next
    end

    created!(
      json: {id: 123, name: name, email: email},
      location: "/api/users/123"
    )
  end

  delete "/api/users/:id" do
    user = User.find?(params["id"])

    unless user
      not_found! json: {error: "User not found"}
      next
    end

    no_content!  # 204 - Deleted successfully
  end

  # ===== ERROR HANDLING DEMO =====

  get "/errors/server" do
    internal_server_error! json: {
      error: "Something went wrong",
      code: "server_error"
    }
  end

  get "/errors/forbidden" do
    forbidden! "You don't have permission to access this resource"
  end

  get "/errors/conflict" do
    conflict! json: {
      error: "Resource already exists",
      field: "email"
    }
  end

  get "/errors/rate-limit" do
    too_many_requests! "Rate limit exceeded", retry_after: 60
  end

  # ===== REDIRECT HELPERS =====

  get "/redirect/temp" do
    found! "/api/users"  # 302
  end

  get "/redirect/permanent" do
    moved_permanently! "/api/v2/users"  # 301
  end

  # ===== HOME =====

  root do
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head><title>DSL Improvements Demo</title></head>
    <body>
      <h1>Orion DSL Improvements Demo</h1>

      <h2>Status Helpers</h2>
      <ul>
        <li><a href="/status/ok">OK (200)</a></li>
        <li><a href="/status/not-found">Not Found (404)</a></li>
        <li><a href="/status/unauthorized">Unauthorized (401)</a></li>
        <li><a href="/status/created">Created (201)</a></li>
        <li><a href="/status/no-content">No Content (204)</a></li>
        <li><a href="/status/head">Head (200 with no body)</a></li>
      </ul>

      <h2>JSON Helpers</h2>
      <ul>
        <li><a href="/json/simple">Simple JSON</a></li>
        <li><a href="/json/users">Users JSON</a></li>
        <li><a href="/json/created">Created JSON (201)</a></li>
        <li><a href="/json/error">Error JSON (400)</a></li>
      </ul>

      <h2>Param Helpers</h2>
      <ul>
        <li><a href="/params/basic?name=John&age=25">Basic Params</a></li>
        <li><a href="/params/path/123/posts/456">Path Params</a></li>
        <li>POST /params/strong (use curl)</li>
      </ul>

      <h2>API Examples</h2>
      <ul>
        <li><a href="/api/users">GET /api/users</a></li>
        <li><a href="/api/users/1">GET /api/users/1</a></li>
        <li><a href="/api/users/999">GET /api/users/999 (Not Found)</a></li>
        <li>POST /api/users (use curl)</li>
        <li>DELETE /api/users/1 (use curl)</li>
      </ul>

      <h2>Error Handling</h2>
      <ul>
        <li><a href="/errors/server">Internal Server Error (500)</a></li>
        <li><a href="/errors/forbidden">Forbidden (403)</a></li>
        <li><a href="/errors/conflict">Conflict (409)</a></li>
        <li><a href="/errors/rate-limit">Rate Limit (429)</a></li>
      </ul>

      <h2>Redirects</h2>
      <ul>
        <li><a href="/redirect/temp">Temporary Redirect (302)</a></li>
        <li><a href="/redirect/permanent">Permanent Redirect (301)</a></li>
      </ul>

      <h2>Example Requests</h2>
      <pre>
# Get all users
curl http://localhost:4000/api/users

# Get single user
curl http://localhost:4000/api/users/1

# Create user
curl -X POST http://localhost:4000/api/users \\
  -d "name=John&email=john@example.com"

# Delete user
curl -X DELETE http://localhost:4000/api/users/1

# Test params
curl http://localhost:4000/params/basic?name=Alice&age=30
      </pre>
    </body>
    </html>
    HTML
  end
end

puts "🚀 DSL Improvements Demo"
puts ""
puts "Available at: http://localhost:4000"
puts ""
puts "New Features:"
puts "  ✓ Status helpers (ok!, not_found!, unauthorized!, etc.)"
puts "  ✓ JSON helpers (json, json_created, json_not_found, etc.)"
puts "  ✓ Param helpers (params[\"name\"], params.permit())"
puts "  ✓ Cleaner error handling"
puts ""

DSLDemo.listen

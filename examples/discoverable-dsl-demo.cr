require "../src/orion"

# Demo: Discoverable DSL with explicit context
# Shows how ctx. prefix makes helpers clear and discoverable

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
    {id: @id, name: @name, email: @email}
  end
end

router DiscoverableDemo do
  # ===== CLEAR AND DISCOVERABLE =====
  # Everything comes from `ctx` - easy to see what's available

  get "/api/users" do |ctx|
    # Type 'ctx.' and your IDE shows all available methods:
    # - ctx.params
    # - ctx.json
    # - ctx.not_found!
    # - ctx.request
    # - ctx.response
    # - etc.

    users = User.all
    ctx.json({
      users: users.map(&.to_h),
      count: users.size
    })
  end

  get "/api/users/:id" do |ctx|
    # Clear where params comes from
    user = User.find?(ctx.params["id"])

    # Clear where not_found! comes from
    unless user
      ctx.not_found! json: {error: "User not found", id: ctx.params["id"]}
      next
    end

    # Clear where json comes from
    ctx.json(user.to_h)
  end

  post "/api/users" do |ctx|
    # Strong parameters - clearly on ctx.params
    user_params = ctx.params.permit("name", "email")

    # Simulate creation
    new_user = User.new(
      123_i64,
      user_params["name"]? || "Unknown",
      user_params["email"]? || "no-email@example.com"
    )

    # Clear where created! comes from
    ctx.created!(
      json: new_user.to_h,
      location: "/api/users/#{new_user.id}"
    )
  end

  put "/api/users/:id" do |ctx|
    user = User.find?(ctx.params["id"])
    ctx.not_found! json: {error: "Not found"} unless user

    # Update simulation
    user_params = ctx.params.permit("name", "email")

    # Return updated user
    ctx.json(user.to_h)
  end

  delete "/api/users/:id" do |ctx|
    user = User.find?(ctx.params["id"])
    ctx.not_found! unless user

    # Deletion successful - no content
    ctx.no_content!
  end

  # ===== ERROR HANDLING =====

  get "/errors/bad-request" do |ctx|
    ctx.bad_request! json: {
      error: "Invalid input",
      fields: ["name", "email"]
    }
  end

  get "/errors/unauthorized" do |ctx|
    ctx.unauthorized! json: {
      error: "Invalid credentials",
      code: "auth_failed"
    }
  end

  get "/errors/server" do |ctx|
    ctx.server_error! json: {
      error: "Something went wrong",
      trace_id: "abc123"
    }
  end

  # ===== QUERY PARAMETERS =====

  get "/search" do |ctx|
    # Access query params via ctx.params
    query = ctx.params["q"]? || ""
    page = ctx.params["page"]? || "1"

    ctx.json({
      query: query,
      page: page,
      results: [] of String
    })
  end

  # ===== PATH PARAMETERS =====

  get "/posts/:post_id/comments/:comment_id" do |ctx|
    # ctx.params merges path and query params
    post_id = ctx.params["post_id"]
    comment_id = ctx.params["comment_id"]
    format = ctx.params["format"]? || "json"

    ctx.json({
      post_id: post_id,
      comment_id: comment_id,
      format: format
    })
  end

  # ===== REDIRECTS =====

  get "/old-path" do |ctx|
    ctx.redirect!("/new-path")
  end

  get "/permanent-redirect" do |ctx|
    ctx.moved!("/new-location")
  end

  # ===== STATUS CODES =====

  get "/accepted" do |ctx|
    ctx.status(202)
    ctx.json({message: "Processing started"})
  end

  get "/head" do |ctx|
    ctx.head(:ok)  # 200 with no body
  end

  # ===== TEXT RESPONSES =====

  get "/text" do |ctx|
    ctx.render_text("Plain text response")
  end

  get "/html" do |ctx|
    ctx.render_html("<h1>HTML Response</h1>")
  end

  # ===== HOME PAGE =====

  root do |ctx|
    ctx.render_html <<-HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Discoverable DSL Demo</title>
      <style>
        body { font-family: system-ui; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        h1 { color: #333; }
        h2 { color: #666; border-bottom: 2px solid #eee; padding-bottom: 0.5rem; }
        ul { line-height: 1.8; }
        code { background: #f5f5f5; padding: 0.2rem 0.4rem; border-radius: 3px; }
        pre { background: #f5f5f5; padding: 1rem; border-radius: 5px; overflow-x: auto; }
      </style>
    </head>
    <body>
      <h1>✨ Discoverable DSL Demo</h1>

      <p><strong>Key Insight:</strong> Everything uses <code>ctx.method</code> - easy to discover via autocomplete!</p>

      <h2>API Endpoints</h2>
      <ul>
        <li><a href="/api/users">GET /api/users</a> - List all users</li>
        <li><a href="/api/users/1">GET /api/users/1</a> - Get user #1</li>
        <li><a href="/api/users/999">GET /api/users/999</a> - Not found example</li>
        <li>POST /api/users - Create user (use curl)</li>
        <li>PUT /api/users/1 - Update user (use curl)</li>
        <li>DELETE /api/users/1 - Delete user (use curl)</li>
      </ul>

      <h2>Error Examples</h2>
      <ul>
        <li><a href="/errors/bad-request">Bad Request (400)</a></li>
        <li><a href="/errors/unauthorized">Unauthorized (401)</a></li>
        <li><a href="/errors/server">Server Error (500)</a></li>
      </ul>

      <h2>Parameter Examples</h2>
      <ul>
        <li><a href="/search?q=crystal&page=2">Search with query params</a></li>
        <li><a href="/posts/123/comments/456?format=html">Path + query params</a></li>
      </ul>

      <h2>Other Features</h2>
      <ul>
        <li><a href="/old-path">Redirect (302)</a></li>
        <li><a href="/permanent-redirect">Permanent Redirect (301)</a></li>
        <li><a href="/accepted">Custom Status (202)</a></li>
        <li><a href="/head">Head Request</a></li>
        <li><a href="/text">Plain Text</a></li>
        <li><a href="/html">HTML Response</a></li>
      </ul>

      <h2>Why ctx. is Better</h2>

      <h3>❌ Implicit (Magic)</h3>
      <pre>get "/users" do
  user = User.find?(params["id"])  # Where does params come from?
  not_found! unless user            # Where does not_found! come from?
  json(user.to_h)                   # Where does json come from?
end</pre>

      <h3>✅ Explicit (Clear)</h3>
      <pre>get "/users" do |ctx|
  user = User.find?(ctx.params["id"])  # Clear: from context
  ctx.not_found! unless user            # Clear: from context
  ctx.json(user.to_h)                   # Clear: from context
end

# Type 'ctx.' and see ALL available methods:
# - params, path_params, query_params
# - json, json_ok, json_created
# - not_found!, unauthorized!, server_error!
# - redirect!, moved!, found!
# - request, response, session, flash
# - and more...</pre>

      <h2>IDE Support</h2>
      <p>With explicit <code>ctx</code>, your IDE can:</p>
      <ul>
        <li>✅ Auto-complete all methods</li>
        <li>✅ Show method signatures</li>
        <li>✅ Jump to definition</li>
        <li>✅ Show documentation</li>
        <li>✅ Catch typos at compile time</li>
      </ul>

      <h2>Example Requests</h2>
      <pre>
# Get all users
curl http://localhost:4000/api/users

# Get single user
curl http://localhost:4000/api/users/1

# Create user
curl -X POST http://localhost:4000/api/users \\
  -d "name=Alice&email=alice@example.com"

# Update user
curl -X PUT http://localhost:4000/api/users/1 \\
  -d "name=Alice Updated&email=alice@example.com"

# Delete user
curl -X DELETE http://localhost:4000/api/users/1

# Search
curl "http://localhost:4000/search?q=crystal&page=2"</pre>

    </body>
    </html>
    HTML
  end
end

puts "🚀 Discoverable DSL Demo"
puts ""
puts "Available at: http://localhost:4000"
puts ""
puts "Why ctx. is better:"
puts "  ✓ Clear where helpers come from (ctx.json, ctx.params)"
puts "  ✓ IDE autocomplete works perfectly"
puts "  ✓ Easy to discover all available methods"
puts "  ✓ Type-safe and compile-time checked"
puts "  ✓ Only 4 extra characters (ctx.)"
puts ""
puts "Compare:"
puts "  ❌ json(data)           - Where does this come from?"
puts "  ✅ ctx.json(data)       - Clear: it's on context"
puts ""

DiscoverableDemo.listen

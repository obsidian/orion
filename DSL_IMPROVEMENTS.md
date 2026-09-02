# Orion DSL Improvements Guide

This document describes the new DSL improvements that make Orion more ergonomic and productive.

## What's New

1. **Status Code Helpers** - Semantic HTTP status methods
2. **JSON Helpers** - Simplified JSON responses
3. **Parameter Helpers** - Unified param access

---

## 1. Status Code Helpers

Replace verbose status code assignments with semantic methods.

### Before
```crystal
get "/not-found" do |c|
  c.response.status_code = 404
  c.response.print "Not found"
end

get "/api/error" do |c|
  c.response.status_code = 400
  c.response.content_type = "application/json"
  c.response.print({error: "Bad request"}.to_json)
end
```

### After
```crystal
get "/not-found" do
  not_found! "Not found"
end

get "/api/error" do
  bad_request! json: {error: "Bad request"}
end
```

### Available Helpers

**2xx Success:**
- `ok!(message)`
- `created!(message, json:, location:)`
- `accepted!(message)`
- `no_content!`

**3xx Redirection:**
- `moved_permanently!(location)`
- `found!(location)`
- `see_other!(location)`
- `not_modified!`
- `temporary_redirect!(location)`
- `permanent_redirect!(location)`

**4xx Client Errors:**
- `bad_request!(message, json:)`
- `unauthorized!(message, json:, www_authenticate:)`
- `forbidden!(message, json:)`
- `not_found!(message, json:)`
- `method_not_allowed!(message, allowed_methods:)`
- `conflict!(message, json:)`
- `unprocessable_entity!(message, json:)`
- `too_many_requests!(message, retry_after:)`

**5xx Server Errors:**
- `internal_server_error!(message, json:)`
- `not_implemented!(message)`
- `bad_gateway!(message)`
- `service_unavailable!(message, retry_after:)`
- `gateway_timeout!(message)`

**Generic:**
- `status(code)` - Set any status code
- `head(status)` - Send status with no body

### Examples

```crystal
# Simple text response
get "/ok" do
  ok! "Everything is fine"
end

# JSON response
get "/api/not-found" do
  not_found! json: {error: "Resource not found", code: 404}
end

# Created with location
post "/api/users" do
  user = create_user(params)
  created! json: user.to_h, location: "/api/users/#{user.id}"
end

# No content (204)
delete "/api/users/:id" do
  delete_user(params["id"])
  no_content!
end

# Head response
get "/health" do
  head :ok
end

# Unauthorized with WWW-Authenticate
get "/protected" do
  unauthorized! "Token required", www_authenticate: "Bearer"
end
```

---

## 2. JSON Helpers

Simplified JSON response rendering.

### Before
```crystal
get "/api/users" do |c|
  users = User.all
  c.response.status_code = 200
  c.response.content_type = "application/json"
  c.response.print({users: users}.to_json)
end
```

### After
```crystal
get "/api/users" do
  users = User.all
  json({users: users})
end
```

### Available Helpers

**Basic:**
- `json(data, status = 200)` - Render JSON
- `jsonp(data, callback:, status:)` - Render JSONP

**With Status:**
- `json_ok(data)` - 200
- `json_created(data)` - 201
- `json_accepted(data)` - 202
- `json_bad_request(data)` - 400
- `json_unauthorized(data)` - 401
- `json_forbidden(data)` - 403
- `json_not_found(data)` - 404
- `json_unprocessable_entity(data)` - 422
- `json_internal_server_error(data)` - 500

### Examples

```crystal
# Basic JSON
get "/api/status" do
  json({status: "ok", version: "1.0"})
end

# With custom status
get "/api/data" do
  json({data: fetch_data}, status: 206)
end

# Created response
post "/api/posts" do
  post = create_post(params)
  json_created(post.to_h)
end

# Error response
get "/api/error" do
  json_bad_request({error: "Invalid input", field: "email"})
end

# JSONP
get "/api/callback" do
  jsonp({result: "data"}, callback: params["callback"]? || "callback")
end

# With serializer
get "/api/users" do
  users = User.all
  json(UserSerializer.new(users))
end
```

---

## 3. Parameter Helpers

Unified access to parameters from all sources.

### Before
```crystal
get "/users/:id" do |c|
  user_id = c.request.path_params["id"]
  search = c.request.query_params["search"]?

  # ...
end
```

### After
```crystal
get "/users/:id" do
  user_id = params["id"]
  search = params["search"]?

  # ...
end
```

### Features

**Unified Access:**
```crystal
# params merges: path_params, query_params
get "/posts/:post_id/comments/:comment_id" do
  post_id = params["post_id"]      # from path
  comment_id = params["comment_id"]  # from path
  page = params["page"]?             # from query string

  json({post_id: post_id, comment_id: comment_id, page: page})
end
```

**Existence Checks:**
```crystal
get "/search" do
  if params.has_key?("query")
    results = search(params["query"])
    json(results)
  else
    bad_request! "Query parameter required"
  end
end
```

**Strong Parameters:**
```crystal
post "/users" do
  # Permit only specific params
  permitted = params.permit("name", "email", "age")

  user = User.create(permitted)
  json_created(user.to_h)
end

# Require nested params (simplified)
post "/article" do
  article_params = params.require("article").permit("title", "body")

  article = Article.create(article_params)
  json_created(article)
end
```

**Type Conversion (planned):**
```crystal
post "/users" do
  name = params["name"]
  age = params.get("age", Int32)  # Convert to Int32
  active = params.get("active", Bool)  # Convert to Bool

  # ...
end
```

**All Keys:**
```crystal
get "/debug" do
  json({
    all_params: params.to_h,
    keys: params.keys
  })
end
```

---

## Real-World Examples

### REST API Endpoint

**Before:**
```crystal
get "/api/users/:id" do |c|
  user_id = c.request.path_params["id"]
  user = User.find?(user_id)

  unless user
    c.response.status_code = 404
    c.response.content_type = "application/json"
    c.response.print({error: "User not found"}.to_json)
    return
  end

  c.response.status_code = 200
  c.response.content_type = "application/json"
  c.response.print(user.to_h.to_json)
end
```

**After:**
```crystal
get "/api/users/:id" do
  user = User.find?(params["id"])
  not_found! json: {error: "User not found"} unless user

  json(user.to_h)
end
```

**Reduction:** 17 lines → 5 lines (70% less code)

---

### Create Resource

**Before:**
```crystal
post "/api/posts" do |c|
  title = c.request.query_params["title"]?
  body = c.request.query_params["body"]?

  unless title && body
    c.response.status_code = 400
    c.response.content_type = "application/json"
    c.response.print({error: "Missing parameters"}.to_json)
    return
  end

  post = Post.create(title: title, body: body)

  c.response.status_code = 201
  c.response.headers["Location"] = "/api/posts/#{post.id}"
  c.response.content_type = "application/json"
  c.response.print(post.to_h.to_json)
end
```

**After:**
```crystal
post "/api/posts" do
  post_params = params.permit("title", "body")
  post = Post.create(post_params)

  created! json: post.to_h, location: "/api/posts/#{post.id}"
end
```

**Reduction:** 18 lines → 5 lines (72% less code)

---

### Error Handling

**Before:**
```crystal
get "/api/protected" do |c|
  token = c.request.headers["Authorization"]?

  unless token && valid_token?(token)
    c.response.status_code = 401
    c.response.headers["WWW-Authenticate"] = "Bearer"
    c.response.content_type = "application/json"
    c.response.print({error: "Unauthorized"}.to_json)
    return
  end

  # Process request
end
```

**After:**
```crystal
get "/api/protected" do
  token = request.headers["Authorization"]?
  unauthorized! json: {error: "Unauthorized"}, www_authenticate: "Bearer" unless token && valid_token?(token)

  # Process request
end
```

---

## Migration Guide

These helpers are **100% backward compatible**. Old code continues to work:

```crystal
# Old way still works
get "/users" do |context : Orion::Server::Context|
  context.response.status_code = 200
  context.response.print "users"
end

# New way available
get "/users" do
  ok! "users"
end
```

### Gradual Adoption

1. **Start with new routes** - Use new helpers for all new code
2. **Refactor incrementally** - Update routes as you touch them
3. **Keep testing** - Tests ensure compatibility

### Best Practices

1. **Use semantic status helpers** instead of numeric codes
2. **Use `json()` helper** for all JSON responses
3. **Use `params` helper** instead of accessing context directly
4. **Use `!` methods** (not_found!, unauthorized!) to be explicit about halting

---

## Complete Example

```crystal
require "orion"

class User
  property id : Int64
  property name : String
  property email : String

  def self.find?(id); end
  def self.all; end
  def to_h; {id: @id, name: @name, email: @email}; end
end

router MyAPI do
  # List users
  get "/api/users" do
    users = User.all
    json({users: users.map(&.to_h), count: users.size})
  end

  # Get user
  get "/api/users/:id" do
    user = User.find?(params["id"])
    not_found! json: {error: "User not found"} unless user

    json(user.to_h)
  end

  # Create user
  post "/api/users" do
    user_params = params.permit("name", "email")
    user = User.create(user_params)

    created! json: user.to_h, location: "/api/users/#{user.id}"
  end

  # Update user
  put "/api/users/:id" do
    user = User.find?(params["id"])
    not_found! json: {error: "User not found"} unless user

    user_params = params.permit("name", "email")
    user.update(user_params)

    json(user.to_h)
  end

  # Delete user
  delete "/api/users/:id" do
    user = User.find?(params["id"])
    not_found! json: {error: "User not found"} unless user

    user.delete
    no_content!
  end

  # Health check
  get "/health" do
    head :ok
  end

  # Error example
  get "/error" do
    internal_server_error! json: {error: "Something went wrong"}
  end
end
```

---

## What's Next

Future improvements being considered:

1. **Auto-import context** - Make `response`, `request`, `session` implicit
2. **Before/after actions** - Controller-level hooks
3. **Auto-generate helpers** - From route paths
4. **Namespace helper** - Clearer than `scope`
5. **Returns shortcut** - `returns: :json` parameter

See `DSL_ANALYSIS.md` for full roadmap.

---

## Feedback

These improvements are brand new! Please try them and provide feedback:
- What works well?
- What's confusing?
- What else would help?

Open issues at: https://github.com/obsidian/orion/issues

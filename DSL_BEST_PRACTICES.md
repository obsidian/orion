# Orion DSL Best Practices

## Explicit Context Pattern (Recommended)

**Use explicit context parameter** for clarity and discoverability.

### ✅ Recommended

```crystal
get "/api/users/:id" do |ctx|
  user = User.find?(ctx.params["id"])
  ctx.not_found! json: {error: "Not found"} unless user
  ctx.json(user.to_h)
end
```

**Why this is better:**
- ✅ **Clear source** - `ctx.` shows where methods come from
- ✅ **IDE support** - Autocomplete works perfectly
- ✅ **Discoverable** - Type `ctx.` to see all methods
- ✅ **Type-safe** - Crystal knows the type
- ✅ **Only 4 chars** - Minimal verbosity

---

## Context Naming

Choose whatever makes sense for your codebase:

```crystal
# Short (recommended for most cases)
get "/users" do |ctx|
  ctx.json(users)
end

# Explicit (good for beginners)
get "/users" do |context|
  context.json(users)
end

# Single letter (very concise)
get "/users" do |c|
  c.json(users)
end

# Custom naming (your preference)
get "/users" do |req|
  req.json(users)
end
```

**Pick one style and stick with it** across your codebase.

---

## Available Methods on Context

When you type `ctx.` your IDE shows:

### Parameters
- `ctx.params["key"]` - Unified params (path + query)
- `ctx.path_params` - Path parameters only
- `ctx.query_params` - Query parameters only
- `ctx.params.permit("name", "email")` - Strong parameters
- `ctx.params.require("user")` - Nested params

### JSON Responses
- `ctx.json(data)` - Render JSON (200)
- `ctx.json_ok(data)` - 200
- `ctx.json_created(data)` - 201
- `ctx.json_not_found(data)` - 404
- `ctx.json_unauthorized(data)` - 401
- etc.

### Status Helpers
- `ctx.ok!("message")` - 200
- `ctx.created!(json:, location:)` - 201
- `ctx.no_content!` - 204
- `ctx.bad_request!(json:)` - 400
- `ctx.unauthorized!(json:)` - 401
- `ctx.forbidden!(json:)` - 403
- `ctx.not_found!(json:)` - 404
- `ctx.server_error!(json:)` - 500
- etc.

### Redirects
- `ctx.redirect!(location)` - 302
- `ctx.moved!(location)` - 301
- `ctx.found!(location)` - 302

### Rendering
- `ctx.render_text(text)` - Plain text
- `ctx.render_html(html)` - HTML

### Low-level
- `ctx.request` - HTTP request
- `ctx.response` - HTTP response
- `ctx.session` - Session (if middleware enabled)
- `ctx.flash` - Flash messages
- `ctx.config` - App configuration

---

## Common Patterns

### REST API Endpoint

```crystal
get "/api/users/:id" do |ctx|
  user = User.find?(ctx.params["id"])
  ctx.not_found! json: {error: "Not found"} unless user

  ctx.json(user.to_h)
end
```

### Create with Validation

```crystal
post "/api/users" do |ctx|
  user_params = ctx.params.permit("name", "email")

  user = User.new(user_params)
  if user.valid?
    user.save
    ctx.created! json: user.to_h, location: "/api/users/#{user.id}"
  else
    ctx.unprocessable! json: {errors: user.errors}
  end
end
```

### Error Handling

```crystal
get "/api/protected" do |ctx|
  token = ctx.request.headers["Authorization"]?

  unless token && valid_token?(token)
    ctx.unauthorized! json: {error: "Invalid token"}
    next
  end

  # Process request
  ctx.json({data: "protected"})
end
```

### Query Parameters

```crystal
get "/api/search" do |ctx|
  query = ctx.params["q"]? || ""
  page = ctx.params["page"]? || "1"
  limit = ctx.params["limit"]? || "25"

  results = search(query, page.to_i, limit.to_i)

  ctx.json({
    query: query,
    page: page.to_i,
    results: results
  })
end
```

### Multiple Sources

```crystal
get "/posts/:post_id/comments/:comment_id" do |ctx|
  # ctx.params merges path and query params
  post_id = ctx.params["post_id"]        # from path
  comment_id = ctx.params["comment_id"]  # from path
  format = ctx.params["format"]?         # from query

  ctx.json({
    post_id: post_id,
    comment_id: comment_id,
    format: format || "json"
  })
end
```

---

## Comparison

### ❌ Avoid: Implicit "Magic"

```crystal
get "/users" do
  # Where do these come from? 🤔
  user = User.find?(params["id"])
  not_found! unless user
  json(user.to_h)
end
```

**Problems:**
- Not clear where `params`, `not_found!`, `json` come from
- IDE can't autocomplete
- Hard to discover what's available
- Confusing for new developers

### ✅ Prefer: Explicit Context

```crystal
get "/users" do |ctx|
  # Clear where everything comes from ✨
  user = User.find?(ctx.params["id"])
  ctx.not_found! unless user
  ctx.json(user.to_h)
end
```

**Benefits:**
- Clear source: everything is on `ctx`
- IDE autocomplete works
- Easy to discover methods (type `ctx.`)
- Beginner-friendly
- Only 4 extra characters

---

## Migration Guide

If you have old code using the implicit pattern:

### Before (Controller-based)
```crystal
class UsersController
  include Orion::Controller

  def show
    user = User.find?(params["id"])
    not_found! unless user
    json(user.to_h)
  end
end
```

This still works! Controllers include helpers directly.

### Before (Inline routes - old style)
```crystal
get "/users/:id" do |context : Orion::Server::Context|
  user_id = context.request.path_params["id"]
  user = User.find?(user_id)

  unless user
    context.response.status_code = 404
    context.response.print "Not found"
    return
  end

  context.response.content_type = "application/json"
  context.response.print user.to_h.to_json
end
```

### After (New style)
```crystal
get "/users/:id" do |ctx|
  user = User.find?(ctx.params["id"])
  ctx.not_found! unless user
  ctx.json(user.to_h)
end
```

**Result:** 14 lines → 4 lines (71% reduction)

---

## IDE Setup

### VS Code with Crystal Extension

When you type `ctx.` you'll see:

```
ctx.
  ├─ params["key"]
  ├─ path_params
  ├─ query_params
  ├─ json(data)
  ├─ json_ok(data)
  ├─ json_created(data)
  ├─ not_found!(json:)
  ├─ unauthorized!(json:)
  ├─ redirect!(location)
  ├─ request
  ├─ response
  ├─ session
  └─ ... and more
```

Hover over any method to see documentation and signatures.

---

## Testing

Context helpers work great in tests too:

```crystal
describe "GET /api/users/:id" do
  it "returns user" do
    response = test_route(MyApp.new, :get, "/api/users/1")
    response.status_code.should eq 200
    response.content_type.should eq "application/json"
  end

  it "returns 404 for missing user" do
    response = test_route(MyApp.new, :get, "/api/users/999")
    response.status_code.should eq 404
  end
end
```

---

## Summary

**Best Practice:**
- ✅ Use explicit context parameter (`ctx`, `context`, `c`, etc.)
- ✅ Access all helpers via context (`ctx.json`, `ctx.params`, etc.)
- ✅ Pick one naming style and be consistent
- ✅ Leverage IDE autocomplete

**Avoid:**
- ❌ Implicit helpers (magic methods appearing from nowhere)
- ❌ Inconsistent naming (mixing `ctx`, `c`, `context`, etc.)
- ❌ Accessing `response` directly when helpers exist

**Result:**
- 🎯 Clear, discoverable code
- 🚀 Great IDE support
- 📚 Easy for new developers
- 🔒 Type-safe and compile-time checked

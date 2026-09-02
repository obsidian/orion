# Orion Middleware & API Tools

This document covers the new middleware and API tools added to Orion for building modern web applications.

## Table of Contents

1. [Session & Cookie Management](#session--cookie-management)
2. [Authentication](#authentication)
3. [Security Middleware](#security-middleware)
4. [API Tools](#api-tools)

---

## Session & Cookie Management

### Session Middleware

Provides stateful sessions with multiple storage backends.

```crystal
require "orion"
require "orion/middleware"

router MyApp do
  # Cookie-based sessions (signed, secure)
  use Orion::Middleware::Session.new(
    secret: ENV["SECRET_KEY_BASE"],
    store: :cookie,
    expire_after: 2.hours
  )

  # Memory-based sessions (development/testing)
  use Orion::Middleware::Session.new(
    secret: ENV["SECRET_KEY_BASE"],
    store: :memory
  )

  # Using sessions in routes
  post "/login" do
    # Set session value
    session[:user_id] = user.id
    session[:email] = user.email

    redirect to: dashboard_path
  end

  get "/dashboard" do
    # Read session value
    user_id = session[:user_id]?
    unless user_id
      redirect to: login_path
      next
    end

    render view: :dashboard
  end

  post "/logout" do
    # Clear session
    session.clear
    redirect to: root_path
  end
end
```

### Flash Messages

```crystal
post "/login" do
  if user = authenticate(params["email"], params["password"])
    session[:user_id] = user.id
    flash[:success] = "Welcome back!"
    redirect to: dashboard_path
  else
    flash[:error] = "Invalid credentials"
    redirect to: login_path
  end
end

# In views
<% if message = flash[:success]? %>
  <div class="alert alert-success"><%= message %></div>
<% end %>

<% if error = flash[:error]? %>
  <div class="alert alert-error"><%= error %></div>
<% end %>
```

---

## Authentication

Orion provides multiple authentication strategies:

### 1. Session-Based Authentication

```crystal
router MyApp do
  use Orion::Middleware::Session.new(secret: ENV["SECRET_KEY_BASE"])

  # Protect all routes under /admin
  scope "/admin" do
    use Orion::Middleware::SessionAuth.new(
      session_key: :user_id,
      redirect_to: "/login"
    )

    get "/dashboard" do
      user_id = Orion::Middleware::SessionAuth.user_id(context)
      render view: :dashboard
    end
  end

  # Login endpoint
  post "/login" do
    user = User.authenticate(params["email"], params["password"])
    if user
      Orion::Middleware::SessionAuth.login(context, user.id)
      redirect to: "/admin/dashboard"
    else
      redirect to: "/login"
    end
  end

  # Logout endpoint
  post "/logout" do
    Orion::Middleware::SessionAuth.logout(context)
    redirect to: "/"
  end
end
```

### 2. JWT Authentication

```crystal
router APIApp do
  # Protect API routes with JWT
  scope "/api" do
    use Orion::Middleware::JWTAuth.new(
      secret: ENV["JWT_SECRET"],
      algorithm: :HS256
    )

    get "/users" do
      # Access JWT payload
      payload = request.jwt_payload
      user_id = payload["user_id"].as_s

      render json: {users: fetch_users(user_id)}
    end
  end

  # Issue tokens
  post "/api/login" do
    user = User.authenticate(params["email"], params["password"])
    if user
      token = Orion::Middleware::JWTAuth.generate_token(
        payload: {
          "user_id" => JSON::Any.new(user.id.to_i64),
          "email" => JSON::Any.new(user.email)
        },
        secret: ENV["JWT_SECRET"],
        expires_in: 24.hours
      )

      render json: {token: token}
    else
      response.status_code = 401
      render json: {error: "Invalid credentials"}
    end
  end
end
```

### 3. API Key Authentication

```crystal
router APIApp do
  use Orion::Middleware::APIKeyAuth.new(
    keys: ENV["API_KEYS"].split(","),
    header_name: "X-API-Key",
    query_param: "api_key"
  )

  get "/api/data" do
    render json: {data: "protected"}
  end
end

# Client usage:
# curl -H "X-API-Key: your-key-here" http://localhost:3000/api/data
# or
# curl http://localhost:3000/api/data?api_key=your-key-here
```

### 4. Basic HTTP Authentication

```crystal
router AdminApp do
  use Orion::Middleware::BasicAuth.new(
    realm: "Admin Area",
    credentials: {
      "admin" => ENV["ADMIN_PASSWORD"],
      "developer" => ENV["DEV_PASSWORD"]
    }
  )

  get "/admin" do
    render view: :admin_dashboard
  end
end
```

### 5. Custom Authentication

```crystal
class CustomAuth < Orion::Middleware::Auth
  def authenticate(context : Orion::Server::Context) : Bool
    # Your custom logic
    token = context.request.headers["X-Custom-Token"]?
    return false unless token

    # Validate token against database, cache, etc.
    validate_custom_token(token)
  end

  def unauthorized_response(context : Orion::Server::Context)
    context.response.status_code = 403
    context.response.print "Access denied"
  end
end

router MyApp do
  use CustomAuth.new
end
```

---

## Security Middleware

### CSRF Protection

Protect against Cross-Site Request Forgery attacks:

```crystal
router MyApp do
  use Orion::Middleware::Session.new(secret: ENV["SECRET_KEY_BASE"])
  use Orion::Middleware::CSRF.new(secret: ENV["SECRET_KEY_BASE"])

  # In forms (views)
  # <input type="hidden" name="csrf_token" value="<%= csrf_token %>">

  post "/users" do
    # CSRF token is automatically validated
    user = User.create(params)
    render json: user
  end
end
```

CSRF helpers in views:

```erb
<!-- Meta tags for AJAX -->
<%= csrf_meta_tags %>
<!-- Generates:
<meta name="csrf-token" content="...">
-->

<!-- Hidden form field -->
<form method="POST" action="/users">
  <%= csrf_hidden_field %>
  <!-- Generates:
  <input type="hidden" name="csrf_token" value="...">
  -->
  <input type="text" name="name">
  <button>Submit</button>
</form>
```

### CORS (Cross-Origin Resource Sharing)

Enable cross-origin requests for APIs:

```crystal
router APIApp do
  # Development: Allow all origins
  use Orion::Middleware::CORS.new(allow_all: true)

  # Production: Specific origins
  use Orion::Middleware::CORS.new(
    origins: ["https://app.example.com", "https://admin.example.com"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    headers: ["Content-Type", "Authorization"],
    exposed_headers: ["X-Total-Count"],
    credentials: true,
    max_age: 3600
  )

  get "/api/users" do
    render json: {users: all_users}
  end
end
```

Preflight requests (OPTIONS) are handled automatically.

### Rate Limiting

Prevent API abuse with rate limiting:

```crystal
router APIApp do
  # IP-based rate limiting
  use Orion::Middleware::RateLimiter.new(
    requests: 100,
    period: 1.minute,
    strategy: :ip
  )

  # Session-based rate limiting
  use Orion::Middleware::Session.new(secret: ENV["SECRET_KEY_BASE"])
  use Orion::Middleware::RateLimiter.new(
    requests: 1000,
    period: 1.hour,
    strategy: :session
  )

  # Custom identifier
  use Orion::Middleware::RateLimiter.new(
    requests: 100,
    period: 1.minute
  ) do |context|
    # Use API key, user ID, or custom logic
    context.request.headers["X-API-Key"]? || "anonymous"
  end

  get "/api/data" do
    # Rate limit headers are automatically added:
    # X-RateLimit-Limit: 100
    # X-RateLimit-Remaining: 95
    # X-RateLimit-Reset: 1634567890

    render json: {data: "response"}
  end
end
```

When rate limit is exceeded, returns HTTP 429 with retry information:

```json
{
  "error": "Rate limit exceeded",
  "retry_after": 45
}
```

---

## API Tools

### JSON Serializers

Build clean, consistent JSON APIs:

```crystal
require "orion/api"

class User
  property id : Int64
  property email : String
  property name : String
  property admin : Bool
  property created_at : Time
  property posts : Array(Post)
end

class UserSerializer < Orion::API::Serializer(User)
  attributes :id, :email, :name

  # Custom attribute with formatting
  attribute :created_at { |user| user.created_at.to_s("%Y-%m-%d") }

  # Conditional attributes
  attribute :admin, if: ->(user : User) { user.admin? }

  # Relationships
  has_many :posts, serializer: PostSerializer
end

# In controller
get "/api/users/:id" do
  user = User.find(params["id"])

  # Serialize single object
  render json: UserSerializer.new(user).to_json
  # Output: {"data": {"id": 1, "email": "...", "name": "...", "created_at": "2025-01-01"}}

  # Include relationships
  render json: UserSerializer.new(user, include: [:posts]).to_json
end

get "/api/users" do
  users = User.all

  # Serialize collection
  render json: UserSerializer.new(users).to_json
  # Output: {"data": [{...}, {...}]}

  # With metadata
  render json: UserSerializer.new(
    users,
    meta: {"total" => JSON::Any.new(users.size.to_i64)}
  ).to_json
end
```

### JSON:API Serializer

Follows the [JSON:API](https://jsonapi.org/) specification:

```crystal
class UserJSONAPISerializer < Orion::API::JSONAPISerializer(User)
  type "users"
  attributes :email, :name
  has_many :posts, type: "posts"
end

get "/api/users/:id" do
  user = User.find(params["id"])
  render json: UserJSONAPISerializer.new(user, include_relationships: true).to_json
end

# Output:
# {
#   "data": {
#     "id": "1",
#     "type": "users",
#     "attributes": {
#       "email": "user@example.com",
#       "name": "John Doe"
#     },
#     "relationships": {
#       "posts": {
#         "data": [
#           {"id": "1", "type": "posts"},
#           {"id": "2", "type": "posts"}
#         ]
#       }
#     }
#   }
# }
```

### Pagination

#### Offset/Limit Pagination

```crystal
require "orion/api"

class UsersController
  include Orion::API::PaginationHelpers

  def index
    users = User.all

    # Automatic pagination from query params
    paginator = paginate(users, per_page: 25)

    # Add Link headers (RFC 5988)
    add_pagination_links(paginator, "/api/users")

    render json: {
      data:       paginator.items,
      pagination: paginator.meta
    }
  end
end

# GET /api/users?page=2&per_page=10

# Response:
# {
#   "data": [...],
#   "pagination": {
#     "current_page": 2,
#     "per_page": 10,
#     "total_pages": 15,
#     "total_count": 150,
#     "has_next_page": true,
#     "has_prev_page": true
#   }
# }

# Link header:
# Link: </api/users?page=3>; rel="next",
#       </api/users?page=1>; rel="prev",
#       </api/users?page=1>; rel="first",
#       </api/users?page=15>; rel="last"
```

#### Cursor-Based Pagination

Better for real-time data and large datasets:

```crystal
def index
  posts = Post.all.sort_by(&.created_at).reverse

  # Cursor pagination
  paginator = cursor_paginate(posts, limit: 25)

  render json: {
    data:       paginator.items,
    pagination: paginator.meta
  }
end

# GET /api/posts?cursor=eyJpZCI6MTIzfQ==&limit=25

# Response:
# {
#   "data": [...],
#   "pagination": {
#     "limit": 25,
#     "has_more": true,
#     "next_cursor": "eyJpZCI6MTQ4fQ=="
#   }
# }
```

---

## Complete Example

A full-featured API with all middleware:

```crystal
require "orion"
require "orion/middleware"
require "orion/api"

router MyAPI do
  # Security
  use Orion::Middleware::CORS.new(
    origins: ["https://app.example.com"],
    credentials: true
  )

  use Orion::Middleware::RateLimiter.new(
    requests: 100,
    period: 1.minute
  )

  # Session & Authentication
  use Orion::Middleware::Session.new(secret: ENV["SECRET_KEY_BASE"])

  # Public endpoints
  post "/api/login" do
    user = User.authenticate(params["email"], params["password"])
    if user
      token = Orion::Middleware::JWTAuth.generate_token(
        payload: {"user_id" => JSON::Any.new(user.id.to_i64)},
        secret: ENV["JWT_SECRET"]
      )
      render json: {token: token}
    else
      response.status_code = 401
      render json: {error: "Invalid credentials"}
    end
  end

  # Protected API routes
  scope "/api" do
    use Orion::Middleware::JWTAuth.new(secret: ENV["JWT_SECRET"])

    get "/users" do
      users = User.all
      paginator = paginate(users)

      render json: UserSerializer.new(paginator.items, meta: paginator.meta).to_json
    end

    get "/users/:id" do
      user = User.find(params["id"])
      render json: UserSerializer.new(user).to_json
    end
  end
end

MyAPI.listen
```

---

## Best Practices

1. **Always use HTTPS in production** with session cookies and authentication
2. **Set secure cookie flags**: `secure: true, http_only: true, same_site: :strict`
3. **Use strong secrets**: Generate with `Random::Secure.hex(64)`
4. **Enable CSRF protection** for all state-changing operations
5. **Set appropriate rate limits** based on your API usage patterns
6. **Use cursor pagination** for large datasets or real-time feeds
7. **Version your API**: `/api/v1/users`, `/api/v2/users`
8. **Include proper CORS headers** for browser-based API clients

---

## Testing

```crystal
describe "API with authentication" do
  it "requires authentication" do
    response = test_route(MyAPI.new, :get, "/api/users")
    response.status_code.should eq 401
  end

  it "works with valid token" do
    token = Orion::Middleware::JWTAuth.generate_token(
      payload: {"user_id" => JSON::Any.new(1_i64)},
      secret: "test_secret"
    )

    response = test_route(
      MyAPI.new,
      :get,
      "/api/users",
      headers: {"Authorization" => "Bearer #{token}"}
    )

    response.status_code.should eq 200
  end
end
```

---

## Migration Guide

If you're upgrading from vanilla Orion, here's how to add these features:

```crystal
# Before
router MyApp do
  get "/users" do
    # Manual JSON response
    users = User.all
    response.content_type = "application/json"
    response.print({users: users}.to_json)
  end
end

# After
require "orion/api"

router MyApp do
  get "/users" do
    users = User.all
    paginator = paginate(users)
    render json: UserSerializer.new(paginator.items).to_json
  end
end
```

---

## Further Reading

- [OWASP CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [CORS Specification](https://fetch.spec.whatwg.org/#http-cors-protocol)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [JSON:API Specification](https://jsonapi.org/)
- [Rate Limiting Patterns](https://en.wikipedia.org/wiki/Rate_limiting)

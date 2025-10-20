require "../src/orion"
require "../src/orion/middleware"
require "../src/orion/api"

# Demo: Complete web application with authentication, sessions, and API

# Mock user class for demonstration
class User
  property id : Int64
  property email : String
  property name : String
  property admin : Bool
  property created_at : Time

  def initialize(@id, @email, @name, @admin = false, @created_at = Time.utc)
  end

  def self.authenticate(email : String, password : String) : User?
    # Mock authentication - in real app, check database
    return User.new(1_i64, email, "Demo User") if email == "demo@example.com" && password == "password"
    nil
  end

  def self.find(id : String) : User
    User.new(id.to_i64, "user#{id}@example.com", "User #{id}")
  end

  def self.all : Array(User)
    (1..50).map { |i| User.new(i.to_i64, "user#{i}@example.com", "User #{i}") }.to_a
  end
end

# JSON Serializer for User
class UserSerializer < Orion::API::Serializer(User)
  attributes :id, :email, :name
  attribute :created_at { |user| user.created_at.to_s("%Y-%m-%d %H:%M:%S") }
  attribute :admin, if: ->(user : User) { user.admin? }
end

router DemoApp do
  # ===== MIDDLEWARE SETUP =====

  # Session management (required for CSRF and flash)
  use Orion::Middleware::Session.new(
    secret: ENV["SECRET_KEY_BASE"]? || "demo_secret_key_change_in_production",
    cookie_name: "_demo_session",
    expire_after: 2.hours
  )

  # CSRF Protection
  use Orion::Middleware::CSRF.new(
    secret: ENV["SECRET_KEY_BASE"]? || "demo_secret_key_change_in_production"
  )

  # CORS for API endpoints
  use Orion::Middleware::CORS.new(
    origins: ["http://localhost:3000"],
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true
  )

  # Rate limiting
  use Orion::Middleware::RateLimiter.new(
    requests: 100,
    period: 1.minute,
    strategy: :ip
  )

  # ===== PUBLIC ROUTES =====

  root do
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head><title>Orion Middleware Demo</title></head>
    <body>
      <h1>Orion Middleware Demo</h1>
      <ul>
        <li><a href="/login">Login Page</a></li>
        <li><a href="/dashboard">Dashboard (Protected)</a></li>
        <li><a href="/api/users">API: Users List</a></li>
        <li><a href="/api/users/1">API: User Detail</a></li>
      </ul>
    </body>
    </html>
    HTML
  end

  get "/login" do
    <<-HTML
    <!DOCTYPE html>
    <html>
    <head><title>Login</title></head>
    <body>
      <h2>Login</h2>
      <form method="POST" action="/login">
        <input type="hidden" name="csrf_token" value="#{csrf_token}">
        <input type="email" name="email" placeholder="demo@example.com" required><br>
        <input type="password" name="password" placeholder="password" required><br>
        <button type="submit">Login</button>
      </form>
    </body>
    </html>
    HTML
  end

  post "/login" do
    # Authenticate user
    user = User.authenticate(
      query_params["email"]? || "",
      query_params["password"]? || ""
    )

    if user
      # Log in via session
      Orion::Middleware::SessionAuth.login(context, user.id)
      flash[:success] = "Welcome back, #{user.name}!"
      response.status_code = 302
      response.headers["Location"] = "/dashboard"
    else
      flash[:error] = "Invalid credentials"
      response.status_code = 302
      response.headers["Location"] = "/login"
    end
  end

  post "/logout" do
    Orion::Middleware::SessionAuth.logout(context)
    flash[:info] = "You have been logged out"
    response.status_code = 302
    response.headers["Location"] = "/"
  end

  # ===== PROTECTED ROUTES =====

  scope "/dashboard" do
    use Orion::Middleware::SessionAuth.new(
      session_key: :user_id,
      redirect_to: "/login"
    )

    root do
      user_id = session[:user_id]?
      <<-HTML
      <!DOCTYPE html>
      <html>
      <head><title>Dashboard</title></head>
      <body>
        <h2>Dashboard</h2>
        <p>Welcome, User ##{user_id}!</p>
        <p>
          <form method="POST" action="/logout">
            <input type="hidden" name="csrf_token" value="#{csrf_token}">
            <button type="submit">Logout</button>
          </form>
        </p>
      </body>
      </html>
      HTML
    end
  end

  # ===== API ROUTES =====

  scope "/api" do
    # JWT Authentication for API
    # In real app, clients would get token from /api/auth/token endpoint
    # use Orion::Middleware::JWTAuth.new(
    #   secret: ENV["JWT_SECRET"]? || "jwt_secret_key"
    # )

    get "/users", helper: "api_users" do
      users = User.all

      # Paginate
      page = query_params["page"]?.try(&.to_i) || 1
      paginator = Orion::API::Paginator.new(
        collection: users,
        page: page,
        per_page: 10
      )

      # Serialize with pagination
      response.content_type = "application/json"
      response.print({
        data:       paginator.items.map { |u| UserSerializer.new(u).as_json["data"] },
        pagination: paginator.meta,
      }.to_json)
    end

    get "/users/:id" do
      user = User.find(path_params["id"])

      # Serialize single user
      response.content_type = "application/json"
      response.print UserSerializer.new(user).to_json
    end

    # Protected API endpoint (would require JWT in real app)
    post "/users" do
      response.content_type = "application/json"
      response.print({
        message: "User creation would happen here",
        note:    "CSRF protection is active",
      }.to_json)
    end
  end

  # ===== RATE LIMIT DEMO =====

  get "/rate-limit-test" do
    response.content_type = "application/json"
    response.print({
      message:   "Request successful",
      remaining: response.headers["X-RateLimit-Remaining"]?,
      limit:     response.headers["X-RateLimit-Limit"]?,
    }.to_json)
  end
end

puts "🚀 Orion Middleware Demo"
puts ""
puts "Available endpoints:"
puts "  - http://localhost:4000/            (Home)"
puts "  - http://localhost:4000/login       (Login page)"
puts "  - http://localhost:4000/dashboard   (Protected page)"
puts "  - http://localhost:4000/api/users   (API with pagination)"
puts "  - http://localhost:4000/api/users/1 (API single user)"
puts ""
puts "Demo credentials:"
puts "  Email: demo@example.com"
puts "  Password: password"
puts ""
puts "Features demonstrated:"
puts "  ✓ Session management"
puts "  ✓ Flash messages"
puts "  ✓ CSRF protection"
puts "  ✓ CORS handling"
puts "  ✓ Rate limiting"
puts "  ✓ Authentication (Session-based)"
puts "  ✓ JSON serialization"
puts "  ✓ Pagination"
puts ""

DemoApp.listen

![Orion](https://raw.githubusercontent.com/obsidian/orion/v3.0.0-dev/orion-banner.svg)

![Build Status](https://travis-ci.org/obsidian/orion.svg?branch=master)
![Tag](https://img.shields.io/github/tag/obsidian/orion.svg?v=1)

---

## Introduction

Orion is minimal, Omni-Conventional, declarative web framework inspired by the ruby-on-rails router and controller components. It provides, the routing, view, and controller framework of your application in a way that can be as simple or complex as you need it to fit your use case.

## Simple
Orion out of the box is designed to be as simple as you want it to be. A few
lines will get you a functioning web app. Orion also ships with helpful features
such as view rendering and static content delivery.

```crystal
require "orion/app"

static "/", dir: "/public"

root do
  render "views/home.slim"
end

get "/login" do
  render "
end
```

## Flexible

```crystal
require "orion/app"
require "auth_handlers"

scope "/api" do
  use AuthHandlers::Token.new
end

use SessionAuthHandler.new

scope constraint: UnauthenticatedUser do
  root do
  render "views/home.slim"
end

get "/login", helper: login do
  render "views/login.slim"
end

post "/login" do
  if User.authenticate(params["email"], params["password])
    redirect to: root_path
  else
    flash[:error] = "Invalid login"
    redirect to: login_path
  end
end

scope constraint: AuthenticatedUser do
  root do
    render "views/dashboard.slim"
  end
end
```
![Orion](https://raw.githubusercontent.com/obsidian/orion/v3.0.0-dev/orion-banner.svg)

[![Crystal CI](https://github.com/obsidian/orion/workflows/Crystal%20CI/badge.svg)](https://github.com/obsidian/orion/actions?query=workflow%3A%22Crystal+CI%22)
[![GitHub issues](https://img.shields.io/github/issues/obsidian/orion)](https://github.com/obsidian/orion/issues)
[![GitHub stars](https://img.shields.io/github/stars/obsidian/orion)](https://github.com/obsidian/orion/stargazers)
[![GitHub license](https://img.shields.io/github/license/obsidian/orion)](https://github.com/obsidian/orion/blob/master/LICENSE)
[![Documentation](https://img.shields.io/badge/Read-Documentation-%232E1052)](https://obsidian.github.io/orion)

---

## Introduction

Orion is minimal, Omni-Conventional, declarative web framework inspired by the ruby-on-rails router and controller components. It provides, the routing, view, and controller framework of your application in a way that can be as simple or complex as you need it to fit your use case.

## Simple Example
Orion out of the box is designed to be as simple as you want it to be. A few
lines will get you a functioning web app. Orion also ships with helpful features
such as view rendering and static content delivery.

```crystal
require "orion/app"

root do
  "Welcome Home"
end

get "/posts" do
  "Many posts here!"
end
```

## Flexible Routing
Orion is extemely flexible, it is inspiried by the rails routing and controller framework and therefore has support for `scope`, `concerns`, `use HTTP::Handler`, `constraints` and more! See the modules in `Orion::DSL` more more detail.

```crystal
require "orion/app"
require "auth_handlers"

static "/", dir: "./assets"

scope "/api" do
  use AuthHandlers::Token
end

use AuthHandlers::CookieSession

scope constraint: UnauthenticatedUser do
  root do
    render "views/home.slim"
  end
end

get "/login", helper: login do
  render "views/login.slim"
end

post "/login" do
  if User.authenticate(params["email"], params["password"])
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

## Installation
Add this to your application's shard.yml:

```yml
dependencies:
  orion:
    github: obsidian/orion
```

See also [Getting Started](https://github.com/obsidian/orion/wiki/Getting-Started).

## Documentation

View the docs at [https://obsidian.github.io/orion](https://obsidian.github.io/orion).
View the guides at [https://github.com/obsidian/orion/wiki](https://github.com/obsidian/orion/wiki).

<p align="center"><img src="https://raw.githubusercontent.com/obsidian/orion/v3.0.0-dev/orion-banner.svg" width="300"></p>

<p align="center">
  <img src="https://travis-ci.org/obsidian/orion.svg?branch=master" />
  <img src="https://img.shields.io/github/tag/obsidian/orion.svg?v=1" />
</p>

<hr />

## Introduction

Orion is minimal, Omni-Conventional, declarative web framework inspired by the ruby-on-rails router and controller components. It provides, the routing, view, and controller framework of your application in a way that can be as simple or complex as you need it to fit your use case.

## Conventions

### App Mode

In it's simplest form you can use Orion in app mode. Here you can use a variety of verbs and helpers. Each block will create its controller and have all the methods of `Orion::BaseController` and will include an URL helpers you have defined within the application.

```crystal
require "orion/app"

use HTTP::LogHandler.new

root "/" do
  "Hello World"
end

get "/posts" do
  @posts = Post.all
  case format
  when .html?
    render "views/post.ecr"
  when .json?
    @posts.to_json
  else
    respond_with_status 404
  end
end

ws "/echo" do
  websocket.on_message do |message|
    websocket.send message
  end
end
```

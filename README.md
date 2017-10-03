# Orion

A minimal, rails'esk routing library for `HTTP::Server`.

Orion allows you to easily add routes, groups, and middleware in order to
construct your application's routing layer.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  orion:
    github: obsidian/orion
```

## Usage

```crystal
require "orion"
```

You can define a router with the following:

```crystal
class SampleRouter < Orion::Router
  # Add handlers/middleware
  use SampleMiddleware.new("at root")

  # Mount an entire application at a path
  mount "app", App.new

  # Add some basic routes
  get "foo/:bar", "SampleController#get"
  get "proc", ->(context : HTTP::Server::Context) {
    context.response.puts "proc"
  }

  # Add grouped routes under a path
  group "in_group" do

    # Add middleware for the group
    use SampleMiddleware.new("in group")

    # some routes for the group
    put ":baz", ->(cxt : HTTP::Server::Context) { cxt.response.puts "?" }
    match ":baz", "SampleController#baz"

    # Keep nesting more groups
    group "in_deeper_group" do
      use SampleMiddleware.new("in deep group")
      get ":taz", "SampleController#taz"
    end

    # Clear all the handlers at the current path
    clear_handlers do
      get "no/handlers", ->(context : HTTP::Server::Context) {
        context.response.puts "no handlers"
      }
    end
  end
  get "callable", Callable
end
```

## Benchmarks

Benchmarks can be run with `./benchmark`.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/orion/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jwaldrip](https://github.com/jwaldrip) Jason Waldrip - creator, maintainer

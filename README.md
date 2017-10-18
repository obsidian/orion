# Orion
[![Build Status](https://travis-ci.org/obsidian/orion.svg?branch=master)](https://travis-ci.org/obsidian/orion)
[![Dependency Status](https://shards.rocks/badge/github/obsidian/orion/status.svg)](https://shards.rocks/github/obsidian/orion)
[![GitHub release](https://img.shields.io/github/release/obsidian/orion.svg)](https://github.com/obsidian/orion/releases)

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

You will need to require orion in your project.

```crystal
require "orion"
```

You must define a class that inherits from `Orion::Router`. You will define your
routes directly in this class.

```crystal
class MyApplicationRouter < Orion::Router
  # ...
end
```

Lets define the routers's `root` route. `root` is simply an alias for `get '/', action`.
All routes can either be a `String` pointing to a Controller action or a `Proc`
accepting `HTTP::Server::Context` as a single argument. If a `String` is used like `controller#action`, it will expand into `Controller.new(context : HTTP::Server::Context).action`, therefor A controller must
have an initializer that takes `HTTP::Server::Context` as an argument, and the
specified action must not contain arguments.

```crystal
  class MyApplicationRouter < Orion::Router
    root to: "home#index"
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

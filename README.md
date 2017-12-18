# Orion
[![Build Status](https://travis-ci.org/obsidian/orion.svg?branch=master)](https://travis-ci.org/obsidian/orion)
[![Dependency Status](https://shards.rocks/badge/github/obsidian/orion/status.svg)](https://shards.rocks/github/obsidian/orion)
[![GitHub release](https://img.shields.io/github/release/obsidian/orion.svg)](https://github.com/obsidian/orion/releases)

A minimal, rails'esk routing library for `HTTP::Server`.

Orion allows you to easily add routes, groups, and middleware in order to
construct your application's routing layer.

## Purpose

The purpose of the Orion router is to connect URLs to code. It provides a flexible
and comprehensive DSL that will allow you to cover a variety of use cases. In addition,
Orion will also generate a series of helpers to easily reference the defined paths
within your application.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  orion:
    github: obsidian/orion
```

... and require Orion in your project.

```crystal
require "orion"
```

## Usage

For a comprehensive guide please see the [github page](https://github.com/obsidian/orion)
or take a look at what you can define inside the `.router` block by looking at some of the
API's:

* `Orion::Router::Resources`
* `Orion::Router::Routes`
* `Orion::Router::Scope`
* `Orion::Router::Middleware`
* `Orion::Router::Concerns`
* `Orion::Router::Constraints`

```crystal
router MyApplicationRouter do
  # ...
end
```

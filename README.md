```text
                     - - -
                   -        -  -     --    -
                -                 -         -  -
                                -
                               -                --
               -          -            -              -
               -            '-,        -               -
               -              'b      *
                -              '$    #-                --
               -    -           $:   #:               -
             --      -  --      *#  @):        -   - -
                          -     :@,@):   ,-**:'   -
              -      -,         :@@*: --**'      -   -
                       '#o-    -:(@'-@*"'  -                  .d88b.   .d8b.  db   dD
               -  -       'bq,--:,@@*'   ,*      -  -        .8P  Y8. d8' `8b 88 ,8P'
                          ,p$q8,:@)'  -p*'      -            88    88 88ooo88 88,8P
                   -     '  - '@@Pp@@*'    -  -              88    88 88~~~88 88`8b
                    -  - --    Y7'.'     -  -                `8b  d8' 88   88 88 `88.
                              :@):.                           `Y88P'  YP   YP YP   YD
                             .:@:'.                          =========================
                           .::(@:.                             A Crystal HTTP Router

```

# Orion

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

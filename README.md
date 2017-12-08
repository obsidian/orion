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

# Oak

A minimal, rails'esk routing library for `HTTP::Server`.

Oak allows you to easily add routes, groups, and middleware in order to
construct your application's routing layer.

## Purpose

The purpose of the Oak router is to connect URLs to code. It provides a flexible
and comprehensive DSL that will allow you to cover a variety of use cases. In addition,
Oak will also generate a series of helpers to easily reference the defined paths
within your application.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  oak:
    github: obsidian/oak
```

... and require Oak in your project.

```crystal
require "oak"
```

## Usage

For a comprehensive guide please see the [github page](https://github.com/obsidian/oak)
or take a look at what you can define inside the `.router` block by looking at some of the
API's:

* `Oak::Router::Resources`
* `Oak::Router::Routes`
* `Oak::Router::Scope`
* `Oak::Router::Middleware`
* `Oak::Router::Concerns`
* `Oak::Router::Constraints`

```crystal
router MyApplicationRouter do
  # ...
end
```

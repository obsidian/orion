# 4.0.0

## New Features

* A new view system allows for users to render views and partials while maintaining a layer of security between the view and controller.
* View helpers allow you do define helpers via a module or block to extend methods into your view layer.
* Built in view helpers.
* Statically served assets created with the `static` macro are now bundled with the binary in release mode and are unpacked when the server starts.


## Breaking Changes

* Views are no longer rendered inline within the controller. Local variable access and instance variables must be passed as a named tuple to the `locals` key on the render method and accessed via `locals[:foo]` within the view.

## Bug Fixes

* Servers created with `require orion/app` were not getting their entire user defined config before booting up. This is now fixed.

# 3.1.0



## New Features

## Breaking Changes

## Bug Fixes

# 3.0.0

## New Features

## Breaking Changes

## Bug Fixes
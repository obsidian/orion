# Handlers allow you to maniplate the request stack by passing instances of classes
# implementing the
# [`HTTP::Handler`](https://crystal-lang.org/api/HTTP/Handler.html) _(a.k.a. middleware)_
# module.
#
# > Handlers will only apply to the routes specified below them, so be sure to place your handlers near the top of your route.
#
# ```crystal
# use HTTP::ErrorHandler
# use HTTP::LogHandler.new(File.open("tmp/application.log"))
# ```
#
# ### Nested Routes using `scope`
#
# Scopes are a method in which you can nest routes under a common path. This prevents
# the need for duplicating paths and allows a developer to easily change the parent
# of a set of child paths.
#
# ```crystal
# scope "users" do
#   root to: "Users#index"
#   get ":id", to: "Users#show"
#   delete ":id", to: "Users#destroy"
# end
# ```
#
# #### Handlers within nested routes
#
# Instances of link:https://crystal-lang.org/api/HTTP/Handler.html[`HTTP::Handler`] can be
# used within a `scope` block and will only apply to the subsequent routes within that scope.
# It is important to note that the parent context's handlers will also be used.
#
# > Handlers will only apply to the routes specified below them, so be sure to place your handlers near the top of your scope.
#
# ```crystal
# scope "users" do
#   use AuthorizationHandler.new
#   root to: "Users#index"
#   get ":id", to: "Users#show"
#   delete ":id", to: "Users#destroy"
# end
# ```
module Orion::DSL::Handlers
  # Insert a new handler. This is the same as `handlers.push(HTTP::LogHandler.new)`
  macro use(handler)
    HANDLERS << {{handler}}
  end

  # Direct access the handlers array, giving you access to methods like `unshift`,
  # `push` and `clear`.
  macro handlers
    HANDLERS
  end
end

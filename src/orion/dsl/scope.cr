# Scopes are a method in which you can nest routes under a common path. This prevents
# the need for duplicating paths and allows a developer to easily change the parent
# of a set of child paths.
#
# ```crystal
# router MyApplicationRouter do
#   scope "users" do
#     root to: "Users#index"
#     get ":id", to: "Users#show"
#     delete ":id", to: "Users#destroy"
#   end
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
# router MyApplicationRouter do
#   scope "users" do
#     use AuthorizationHandler.new
#     root to: "Users#index"
#     get ":id", to: "Users#show"
#     delete ":id", to: "Users#destroy"
#   end
# end
# ```
module Orion::DSL::Scope
  # Create a scope, optionall nested under a path.
  macro scope(path = nil, helper_prefix = nil, controller = nil)
    {% prefixes = PREFIXES + [helper_prefix] if helper_prefix %}
    {% scope_const = run "../inflector/random_const.cr", "Scope" %}

    # :nodoc:
    module {{ scope_const }}
      include ::Orion::DSL::Macros

      CONSTRAINTS = {% if @type.stringify != "<Program>" %}::{{ @type }}{% end %}::CONSTRAINTS.dup
      HANDLERS = {% if @type.stringify != "<Program>" %}::{{ @type }}{% end %}::HANDLERS.dup

      # Set the controller
      {% if controller %}
        CONTROLLER = {{ controller }}
      {% end %}

      # Set the base path
      {% if path %}
        BASE_PATH = [{% if @type.stringify != "<Program>" %}::{{ @type }}{% end %}::BASE_PATH.rchop('/'), {{ path }}.lchop('/')].join('/')
        use Orion::Handlers::ScopeBasePath.new(BASE_PATH)
      {% else %}
        BASE_PATH = {% if @type.stringify != "<Program>" %}::{{ @type }}{% end %}::BASE_PATH
      {% end %}

      # Setup the helper prefixes
      {% if helper_prefix %}
        PREFIXES = {{ prefixes }}
      {% end %}

      # Yield the block
      {{ yield }}
    end
  end
end

# Concerns allow you to create a pattern or concern that you wish
#
# to repeat across scopes or resources in your router.
# #### Defining a concern
#
# To define a concern call `concern` with a `Symbol` for the name.
#
# ```crystal
# concern :authenticated do
#   use Authentication.new
# end
# ```
# #### Using concerns
#
# Once a concern is defined you can call `implements` with a named concern from
# anywhere in your router.
#
# ```crystal
# concern :authenticated do
#   use Authentication.new
# end

# scope "users" do
#   implements :authenticated
#   get ":id"
# end
# ```
module Orion::DSL::Concerns
  macro concern(name, &block)
    {% CONCERNS[name] = block.body.stringify %}
  end

  macro implements(*names)
    {% for name in names %}
      {{ CONCERNS[name].id }}
    {% end %}
  end
end

# Constraints can be used to further determine if a route is hit beyond just it's path. Routes have some predefined constraints you can specify, but you can also
# pass in a custom constraint.
#
# #### Parameter constraints
#
# When defining a route, you can pass in parameter constraints. The path params will
# be checked against the provided regex before the route is chosen as a valid route.
#
# ```crystal
# get "users/:id", constraints: { id: /[0-9]{4}/ }
# ```
#
# #### Format constraints
#
# You can constrain the request to a certain format. Such as restricting
# the extension of the URL to '.json'.
#
# ```crystal
# get "api/users/:id", format: "json"
# ```
#
# #### Request Mime-Type constraints
#
# You can constrain the request to a certain mime-type by using the `content_type` param
# on the route. This will ensure that if the request has a body, it will provide the proper
# content type.
#
# ```crystal
# put "api/users/:id", content_type: "application/json"
# ```
#
# #### Response Mime-Type constraints
#
# You can constrain the response to a certain mime-type by using the `accept` param
# on the route. This is similar to the format constraint but allows clients to
# specify the `Accept` header rather than the extension.
#
# > Orion will automatically add mime-type headers for requests with no Accept header and a specified extension.
#
# ```crystal
# get "api/users/:id", accept: "application/json"
# ```
#
# #### Combined Mime-Type constraints
#
# You can constrain the request and response to a certain mime-type by using the `type` param
# on the route. This will ensure that if the request has a body, it will provide the proper
# content type. In addition, it will also validate that the client provides a proper
# accept header for the response.
#
# Orion will automatically add mime-type headers for requests with no Accept header and
# a specified extension.
#
# ```crystal
# put "api/users/:id", type: "application/json"
# ```
#
# #### Host constraints
#
# You can constrain the request to a specific host by wrapping routes
# in a `host` block. In this method, any routes within the block will be
# matched at that constraint.
#
# You may also choose to limit the request to a certain format. Such as restricting
# the extension of the URL to '.json'.
#
# ```crystal
# host "example.com" do
#   get "users/:id", format: "json"
# end
# ```
#
# #### Subdomain constraints
#
# You can constrain the request to a specific subdomain by wrapping routes
# in a `subdomain` block. In this method, any routes within the block will be
# matched at that constraint.
#
# You may also choose to limit the request to a certain format. Such as restricting
# the extension of the URL to '.json'.
#
# ```crystal
# subdomain "api" do
#   get "users/:id", format: "json"
# end
# ```
#
# #### Custom Constraints
#
# You can also pass in your own constraints by just passing a class/struct that
# implements the `Orion::Constraint` module.
#
# ```crystal
# struct MyConstraint
#   def matches?(req : HTTP::Request)
#     true
#   end
# end
#
# constraint MyConstraint.new do
#   get "users/:id", format: "json"
# end
# ```
module Orion::DSL::Constraints
  # :nodoc:
  CONSTRAINTS = [] of Constraint

  # Constrain routes by an `Orion::Constraint`
  macro constraint(constraint)
    constraints({{ constraint }}) do
      {{ yield }}
    end
  end

  # Constrain routes by one or more `Orion::Constraint`s
  macro constraints(*constraints)
    scope do
      {% for constraint, i in constraints %} # Add the array of provided constraints
        CONSTRAINTS << {{ constraint }}
      {% end %}
      {{ yield }}
    end
  end

  # Constrain routes by a given domain
  macro host(host)
    constraint(::Orion::HostConstraint.new({{ host }})) do
      {{ yield }}
    end
  end

  # Constrain routes by a given subdomain
  macro subdomain(subdomain)
    constraint(::Orion::SubdomainConstraint.new({{ subdomain }})) do
      {{ yield }}
    end
  end
end

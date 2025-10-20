require "json"

module Orion::API
  # TODO: Serializer implementation needs redesign
  #
  # The original implementation attempted to use dynamic method calling and
  # class variables with generic types, which Crystal doesn't support well.
  #
  # ## The Problem
  #
  # Crystal's type system is static and doesn't support:
  # - Dynamic method calling (like Ruby's `object.send(method_name)`)
  # - Class variables in generic classes (type parameter inference fails)
  # - Runtime method name interpolation (`object.{{ attr.id }}` only works in macros)
  #
  # ## Workarounds for Now
  #
  # Use Crystal's built-in JSON serialization:
  #
  # ```crystal
  # class User
  #   include JSON::Serializable
  #
  #   property id : Int64
  #   property name : String
  #   property email : String
  #
  #   @[JSON::Field(ignore: true)]
  #   property password_hash : String
  # end
  #
  # user.to_json  # Automatically serializes
  # ```
  #
  # Or create simple serializer methods:
  #
  # ```crystal
  # class User
  #   def to_api_json
  #     {
  #       id: @id,
  #       name: @name,
  #       email: @email,
  #       created_at: @created_at.to_s("%Y-%m-%d")
  #     }.to_json
  #   end
  # end
  # ```
  #
  # ## Future Improvements
  #
  # Possible approaches that would work with Crystal:
  # - Use macros to generate serialization methods at compile time
  # - Create a simpler builder pattern without generics
  # - Leverage JSON::Serializable with custom converters
  # - Build a macro-based DSL that generates code rather than using runtime reflection
end

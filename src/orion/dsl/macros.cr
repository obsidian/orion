# :nodoc:
module Orion::DSL::Macros
  private macro included
    include ::Orion::DSL::Concerns
    include ::Orion::DSL::Constraints
    include ::Orion::DSL::Handlers
    include ::Orion::DSL::Helpers
    include ::Orion::DSL::Match
    include ::Orion::DSL::Mount
    include ::Orion::DSL::RequestMethods
    include ::Orion::DSL::WebSockets
    include ::Orion::DSL::Root
    include ::Orion::DSL::Scope
    include ::Orion::DSL::Resources
    include ::Orion::DSL::Static
  end
end

module Orion::DSL::Macros
  macro included
    include ::Orion::DSL::Concerns
    include ::Orion::DSL::Constraints
    include ::Orion::DSL::Handlers
    include ::Orion::DSL::Helpers
    include ::Orion::DSL::Routes
    include ::Orion::DSL::Scope
    include ::Orion::DSL::Resources
    include ::Orion::DSL::Static
  end
end

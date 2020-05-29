# Define a new router
macro router(name)
  module {{ name }}
    include Orion::DSL

    def self.new(*args, **opts)
      ::Orion::Router.new(TREE, *args, **opts)
    end

    def self.start(*args, **opts)
      ::Orion::Router.start(TREE, *args, **opts)
    end

    {{ yield }}
  end
end

# Define a new router
macro router(name)
  module {{ name }}
    include Orion::DSL

    {{ yield }}
  end
end

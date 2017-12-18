# Define a new router
macro router(name)
  class {{ name }} < ::Orion::Router
    scope "/" do
      {{ yield }}
    end
  end
end

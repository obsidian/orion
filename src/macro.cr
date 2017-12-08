macro router(name)
  class {{ name }} < ::Oak::Router
    scope "/" do
      {{yield}}
    end
  end
end

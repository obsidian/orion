module Orion::Router::BuiltIns
  macro static(base_path, public_dir)
    scope {{ base_path }} do
      use Orion::StaticFileHandler.new({{ public_dir }})
    end
  end
end

module Orion::Cache::Keyable
  macro define_cache_key(*keys)
    def cache_key : String
      {{ keys.map(&.id) }}.join("-")
    end
  end

  abstract def cache_key : String
end

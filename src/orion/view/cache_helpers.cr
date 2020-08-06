module Orion::View::CacheHelpers
  # Cache the block, using the object as the key
  macro cache(object, &block)
    %orig_cache_key = __cache_key__
    __cache_key__ = extend_cache_key(__cache_key__, {{ object }})
    config.cache.fetch(__cache_key__) do
      String.build do |__kilt_io__|
        {{ yield }}
      end
    end.to_s(__kilt_io__)
    __cache_key__ = %orig_cache_key
  end

  # Cache the block, if the condition is true, using the object as the key
  macro cache_if(condition, object, &block)
    %orig_cache_key = __cache_key__
    __cache_key__ = extend_cache_key(__cache_key__, {{ object }})
    config.cache.fetch_if({{ condition }}, __cache_key__) do
      String.build do |__kilt_io__|
        {{ yield }}
      end.to_s(__kilt_io__)
    end
    __cache_key__ = %orig_cache_key
  end

  #
  private def extend_cache_key(prev_key : String, next_key : String)
    "#{prev_key}/#{next_key}"
  end

  private def extend_cache_key(prev_key : String, next_key : Cache::Keyable)
    "#{prev_key}/#{next_key.cache_key}"
  end
end

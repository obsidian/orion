require "cache"

class Orion::Cache
  @store : ::Cache::Store(String, String)

  def initialize(@store = ::Cache::NullStore(String, String).new(expires_in: 0.seconds))
  end

  delegate read, write, fetch, delete, clear, to: @store

  # Read an item from cache
  def read(keyable : Keyable)
    read(keyable.cache_key)
  end

  # Write an item to cache
  def write(keyable : Keyable, value)
    write(keyable.cache_key, value)
  end

  # Read the item from cache, if it doesn't exist, invoke the block
  def fetch(key : Keyable, &block)
    fetch(keyable.cache_key, &block)
  end

  # If the conition is true invoke `fetch`
  def fetch_if(condition, key, &block)
    condition ? fetch(key, &block) : yield
  end

  # Delete the item from cache
  def delete(keyable : Keyable, value)
    delete(keyable.cache_key, value)
  end
end

require "./cache/*"

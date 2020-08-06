require "cache"

class Orion::Cache
  @store : ::Cache::Store(String, String)

  def initialize(@store = ::Cache::NullStore(String, String).new(expires_in: 0.seconds))
  end

  delegate read, write, fetch, delete, clear, to: @store

  def read(keyable : Keyable)
    read(keyable.cache_key)
  end

  def write(keyable : Keyable, value)
    write(keyable.cache_key, value)
  end

  def fetch(key : Keyable, &block)
    fetch(keyable.cache_key, &block)
  end

  def fetch_if(condition, key, &block)
    condition ? fetch(key, &block) : yield
  end

  def delete(keyable : Keyable, value)
    delete(keyable.cache_key, value)
  end
end

require "./cache/*"

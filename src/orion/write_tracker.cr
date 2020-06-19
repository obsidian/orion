# :nodoc:
class Orion::WriteTracker < IO
  getter written : Bool = false

  def read(slice : Bytes)
    raise "Cannot read from write tracker"
  end

  def write(slice : Bytes) : Int64
    return 0i64 if slice.empty?
    @written = true
    slice.size.to_i64
  end
end

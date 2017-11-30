module Orion::Radix
  class Node
    enum Kind : UInt8
      Normal
      Named
      Glob
    end

    include Comparable(self)

    property children = [] of Node
    property! payload : Payload?
    getter key : String
    getter priority : Int32
    getter? placeholder

    protected getter kind = Kind::Normal

    delegate normal?, named?, glob?, to: @kind
    protected delegate sort!, to: @children

    def initialize(@key : String, @payload : Payload? = nil, *, @placeholder = false)
      @priority = compute_priority
    end

    def <=>(other : self)
      result = kind <=> other.kind
      return result if result != 0

      other.priority <=> priority
    end

    def key=(@key)
      # reset kind on change of key
      @kind = Kind::Normal
      @priority = compute_priority
    end

    private def compute_priority
      reader = Char::Reader.new(@key)

      while reader.has_next?
        case reader.current_char
        when '*'
          @kind = Kind::Glob
          break
        when ':'
          @kind = Kind::Named
          break
        else
          reader.next_char
        end
      end

      reader.pos
    end

  end
end

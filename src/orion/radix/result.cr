module Orion::Radix
  class Result
    @key : String?
    @nodes = [] of Node

    getter params = {} of String => String
    getter! payload : Payload

    def found?
      !!payload?
    end

    def key
      @key ||= String.build do |io|
        @nodes.each do |node|
          io << node.key
        end
      end
    end

    def use(node : Node, payload = true)
      @nodes << node
      @payload = node.payload if payload && node.payload?
    end

  end
end

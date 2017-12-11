abstract class Orion::Router
  BASE_MODULE = nil

  private struct Payload
    getter handlers : Array(HTTP::Handler)
    getter proc : HTTP::Handler::Proc
    getter label : String

    def initialize(@handlers, @proc, @label); end
  end

  private alias Tree = Oak::Tree(Payload)

  private macro inherited_child
    BASE_PATH = "/"
    ROUTES = {} of String => Hash(Symbol, Payload)
    HANDLERS = [] of HTTP::Handler

    # Instance vars
    @routes = ROUTES
    @handlers = [] of HTTP::Handler

    # Create the trees
    {% for method in METHODS %}
      {{method.id}}_TREE = Tree.new
    {% end %}

    # Lookup the proper tree
    private def get_tree(method)
      {% begin %}
        case method
        {% for method in METHODS %}
        when {{method.downcase}}
          {{method.id}}_TREE
        {% end %}
        else
          Tree.new
        end
      {% end %}
    end
  end

  private macro inherited_grandchild
    HANDLERS = {{@type.superclass}}::HANDLERS + ([] of HTTP::Handler)
  end

  private macro inherited
    GROUP_COUNTER = [0]

    {% if @type.superclass == Orion::Router %}
      inherited_child
    {% else %}
      inherited_grandchild
    {% end %}

    private def self.normalize_path(path)
      parts = [BASE_PATH, path]
      String.build do |str|
        parts.each_with_index do |part, index|
          part.check_no_null_byte

          str << "/" if index > 0

          byte_start = 0
          byte_count = part.bytesize

          if index > 0 && part.starts_with?("/")
            byte_start += 1
            byte_count -= 1
          end

          if index != parts.size - 1 && part.ends_with?("/")
            byte_count -= 1
          end

          str.write part.unsafe_byte_slice(byte_start, byte_count)
        end
      end
    end

    private def self.use(handler : HTTP::Handler)
      HANDLERS << handler
    end
  end
end

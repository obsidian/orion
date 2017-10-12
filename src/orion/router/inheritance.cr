require "shell-table"
require "radix"
require "http"

abstract class Orion::Router
  BASE_MODULE = nil

  private macro inherited_grandchild

  end

  private macro inherited
    redefine_use({{ @type.superclass == Orion::Router }})

    GROUP_COUNTER = [0]

    {% if @type.superclass == Orion::Router %}
      define_methods
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
  end

end

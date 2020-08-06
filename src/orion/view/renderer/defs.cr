def tokenize(string)
  string.sub(/^\.\/src\/views\//, "").gsub(/[^A-Za-z0-9_]/, "_")
end

Dir.glob("./src/views/**/*").each do |view|
  token = tokenize(view)
  puts <<-crystal

    # :nodoc:
    def __template_#{token}__(__cache_key__ : String, *locals, &block)
      __locals__ = locals = combine_locals(*locals)
      Kilt.embed "#{ view }"
    end

    # :nodoc:
    def __template_#{token}__(__cache_key__ : String, *locals)
      __locals__ = locals = combine_locals(*locals)
      Kilt.embed "#{ view }"
    end

    # :nodoc:
    def __template_string_#{token}__(__cache_key__ : String, *locals)
      __locals__ = locals = combine_locals(*locals)
      Kilt.render "#{ view }"
    end

    # :nodoc:
    def __template_string_#{token}__(__cache_key__ : String, *locals, &block : Symbol -> String)
      __locals__ = locals = combine_locals(*locals)
      Kilt.render "#{ view }"
    end

  crystal
end

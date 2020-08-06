module Orion::View::CaptureHelper
  @content_fors : Hash(Symbol, String)

  # The capture macro allows you to extract part of a template into a variable.
  # You can then use this variable anywhere in your templates or layout.
  macro capture(&block)
    String.build do |__kilt_io__|
      {{ yield }}
    end
  end

  macro content_for(name, &block)
    @content_fors[{{ name }}] = capture do
      {{ yield }}
    end
  end
end

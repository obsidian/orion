macro outer
  puts "outer"
  inner do
    {{ yield }}
  end
end

macro inner
  puts "inner"
  {{ yield }}
end

outer do
  puts "inside"
end

require 'json'

def test
  obj = Struct.new(:a,:b)
  x = obj.new('a','b')

  File.open('test.txt', 'w') do |f|
    f.puts "string"
    f.puts x[:a].to_json
    f.puts x[:b].to_json
    f.close
  end

end

test
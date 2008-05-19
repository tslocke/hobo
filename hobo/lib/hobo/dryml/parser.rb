%w[base_parser attribute document element elements source text tree_parser].each do |lib|
  require "hobo/dryml/parser/#{lib}"
end

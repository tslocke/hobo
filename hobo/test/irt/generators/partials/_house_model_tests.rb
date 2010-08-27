desc "All Model files exists"
files_exist? %w[ app/models/house.rb
   test/unit/house_test.rb
   test/fixtures/houses.yml
   app/viewhints/house_hints.rb ]
test_value_eql? true

desc "Model injection matches"
file_include? 'app/models/house.rb',
              'hobo_model',
              'fields do',
              /alpha\s+\:string/
test_value_eql? true

desc "Hint content matches"
file_include? 'app/viewhints/house_hints.rb',
              'class HouseHints'
test_value_eql? true

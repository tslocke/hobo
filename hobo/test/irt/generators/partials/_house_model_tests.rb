desc "All Model files exists"
files_exist? %w[ app/models/house.rb ]
test_value_eql? true

desc "Model injection matches"
file_include? 'app/models/house.rb',
              'hobo_model',
              'fields do',
              /alpha\s+\:string/
test_value_eql? true

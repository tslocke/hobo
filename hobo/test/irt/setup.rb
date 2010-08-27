#!/usr/bin/env ruby

puts %(Please chose 'no' at the next prompt)
sleep 2
system %(hobo new testapp)
system %(cd testapp && echo "gem 'irt', '>= 0.6.0', :group => :console" >> Gemfile)
system %(cd testapp && git init && git add . && git commit -m "initial commit")
puts %(Please cd into the 'testapp' dir and run `irt ../` or `../path/to/test.irt` )
puts %(After running the tests you can remove the testapp dir)

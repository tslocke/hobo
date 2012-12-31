# Instant Front End: Just Add Schema to Hobo

Originally written by allen13 on 2010-10-26.

My personal holy grail of web programming is to take any database and then convert it into a CRUD complete webstie at the click of a button. Yesterday I realized I could get half way there with little effort using tools I already have. I used my old friends sed and awk to parse a rails schema into hobo generator format.

Here is the ruby script I came up with (you have to manually set the rails version for now):

    #!/usr/bin/ruby

    require 'rubygems'
    require 'active_support/inflector'
    
    RAILS_VERSION = 2

    schema = `cat #{ARGV[0]} | sed '/#/d' | sed '/ActiveRecord/d' | sed '/<end>/d' | sed '/add_index/d' | awk '{print $2":"$1" "}'`
    

    schema.gsub!(/t\./,'')
    schema.gsub!(/,/,'')
    schema.gsub!(/\"/,'')

    xs = schema.split(/\n/)

    xs.delete_if {|line| line[0] == 58}

    xs.map! do |line|
      if(line[/create_table/])
        line.gsub!(/.create_table/,'').chop!
        line = line.pluralize.singularize
        if(RAILS_VERSION < 3)
          $/ + "script/generate hobo_resource " + line + ' '
        else
          $/ + "rails generate hobo:resource " + line + ' '
        end
      else
        line 
      end
    end

    puts xs.to_s


Run the above script on a schema file dumped by rake (rake db:schema:dump while connected to the target database):

    ActiveRecord::Schema.define(:version => 20101025160107) do
      create_table "addresses", :primary_key => "addressid", :force => true do |t|
          t.string "street",         :limit => 100
          t.string "postcode",        :limit => 100
          t.string "townname",        :limit => 100
          t.string "provincename",    :limit => 100
          t.string "homephonenumber", :limit => 100
       end
    end

Output:

Rails 2.X

    script/generate hobo_resource address street:string postcode:string townname:string provincename:string homephonenumber:string

Rails 3.X

    rails generate hobo:resource address street:string postcode:string townname:string provincename:string homephonenumber:string






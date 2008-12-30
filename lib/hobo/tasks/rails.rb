# This file is used to load the Hobo rake tasks when running Hobo as a gem

tasks_home = File.join File.dirname(__FILE__), "..", "..", "..", "tasks"
Dir["#{tasks_home}/**/*.rake"].sort.each { |ext| load ext }

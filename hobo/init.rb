require File.dirname(__FILE__) + "/lib/hobo"
require 'rails_generator'

# 'orrible but 'reative 'ack to allow generators to be in symlinked plugins
Rails::Generator::PathSource.class_eval do
  def path
    @path.gsub('**', '*/**')
  end
end
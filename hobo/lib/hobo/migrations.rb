module Hobo::Migrations
  
  class << self
    attr_accessor :ignore_tables
    attr_accessor :ignore_models
    attr_accessor :ignore
  end
  self.ignore_tables = []
  self.ignore_models = []
  self.ignore = []
  
end

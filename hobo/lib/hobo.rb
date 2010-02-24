# gem dependencies
require 'hobosupport'
require 'hobofields'
begin
  require 'will_paginate'
rescue MissingSourceFile
  # OK, Hobo won't do pagination then
end

ActiveSupport::Dependencies.load_paths |= [ File.dirname(__FILE__)]

# Hobo can be installed in /vendor/hobo, /vendor/plugins/hobo, vendor/plugins/hobo/hobo, etc.
::HOBO_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

class HoboError < RuntimeError; end

module Hobo

  VERSION = "1.1.0.pre0"
  
  class PermissionDeniedError < RuntimeError; end

  class RawJs < String; end

  @models = []

  class << self


    attr_accessor :current_theme
    attr_writer :developer_features


    def developer_features?
      @developer_features
    end


    def raw_js(s)
      RawJs.new(s)
    end


    def find_by_search(query, search_targets=nil)
      search_targets ||=
        begin
          # FIXME: This should interrogate the model-router directly, there's no need to enumerate models
          # By default, search all models, but filter out...
          Hobo::Model.all_models.select do |m|
            ModelRouter.linkable?(m, :show) &&  # ...non-linkables
              m.search_columns.any?             # and models with no search-columns
          end
        end

      query_words = ActiveRecord::Base.connection.quote_string(query).split

      search_targets.build_hash do |search_target|
        conditions = []
        parameters = []
        like_operator = ActiveRecord::Base.connection.adapter_name =~ /postgres/i ? 'ILIKE' : 'LIKE'
        query_words.each do |word|
          column_queries = search_target.search_columns.map { |column| "#{column} #{like_operator} ?" }
          conditions << "(" + column_queries.join(" or ") + ")"
          parameters.concat(["%#{word}%"] * column_queries.length)
        end
        conditions = conditions.join(" and ")

        results = search_target.find(:all, :conditions => [conditions, *parameters])
        [search_target.name, results] unless results.empty?
      end
    end

    def add_routes(m)
      Hobo::ModelRouter.add_routes(m)
    end


    def simple_has_many_association?(array_or_reflection)
      refl = array_or_reflection.respond_to?(:proxy_reflection) ? array_or_reflection.proxy_reflection : array_or_reflection
      return false unless refl.is_a?(ActiveRecord::Reflection::AssociationReflection)
      refl.macro == :has_many and
        (not refl.through_reflection) and
        (not refl.options[:conditions])
    end

    def subsites
      # Any directory inside app/controllers defines a subsite
      @subsites ||= Dir["#{RAILS_ROOT}/app/controllers/*"].map { |f| File.basename(f) if File.directory?(f) }.compact
    end
    
    public

    def enable
      require 'action_view_extensions/helpers/tag_helper'

      # Modules that must *not* be auto-reloaded by activesupport
      # (explicitly requiring them means they're never unloaded)
      require 'hobo/model_router'
      require 'hobo/undefined'
      require 'hobo/user'
      require 'dryml'
      require 'dryml/template'
      require 'dryml/dryml_generator'

      Hobo::Model.enable
      Dryml.enable(["#{HOBO_ROOT}/rapid_generators"], "#{RAILS_ROOT}/app/views/taglibs/auto")
      Hobo::Permissions.enable
      Hobo::ViewHints.enable
      
      Hobo.developer_features = RAILS_ENV.in?(["development", "test"]) if Hobo.developer_features?.nil?

      require 'hobo/dev_controller' if RAILS_ENV == Hobo.developer_features?

      ActionController::Base.send(:include, Hobo::ControllerExtensions)

      HoboFields.never_wrap(Hobo::Undefined) if defined? HoboFields

      ActiveSupport::Dependencies.load_paths |= [ "#{RAILS_ROOT}/app/viewhints" ]
    end

  end

  ControllerExtensions = classy_module do
    def self.hobo_user_controller(model=nil)
      @model = model
      include Hobo::ModelController
      include Hobo::UserController
    end

    def self.hobo_model_controller(model=nil)
      @model = model
      include Hobo::ModelController
    end

    def self.hobo_controller
      include Hobo::Controller
    end

  end

  # Empty class to represent the boolean type.
  class Boolean; end

end


# Add support for type metadata to arrays
class ::Array

  attr_accessor :member_class, :origin, :origin_attribute

  def to_url_path
    base_path = origin_object.try.to_url_path
    "#{base_path}/#{origin_attribute}" unless base_path.blank?
  end

  def typed_id
    origin and origin_id = origin.try.typed_id and "#{origin_id}:#{origin_attribute}"
  end

end


module ::Enumerable
  def group_by_with_metadata(&block)
    r=group_by_without_metadata(&block)
    r.each do |k,v|
      v.origin = origin
      v.origin_attribute = origin_attribute
      v.member_class = member_class
    end
    r
  end
  alias_method_chain :group_by, :metadata
end


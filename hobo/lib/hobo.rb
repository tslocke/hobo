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

  VERSION = "0.8.5"
  
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


    def typed_id(obj, attr=nil)
      attr ? "#{obj.typed_id}:#{attr}" : obj.typed_id
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
        query_words.each do |word|
          column_queries = search_target.search_columns.map { |column| "#{column} like ?" }
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


    def get_field(object, field)
      return nil if object.nil?
      field_str = field.to_s
      if field_str =~ /^\d+$/
        object[field.to_i]
      else
        object.send(field)
      end
    end


    def get_field_path(object, path)
      path = if path.is_a? String
               path.split('.')
             else
               Array(path)
             end

      field, parent = nil
      path.each do |field|
        return nil if object.nil?
        parent = object
        object = get_field(parent, field)
      end
      [parent, field, object]
    end


    def static_tags
      @static_tags ||= begin
                         path = if FileTest.exists?("#{RAILS_ROOT}/config/dryml_static_tags.txt")
                                    "#{RAILS_ROOT}/config/dryml_static_tags.txt"
                                else
                                    File.join(File.dirname(__FILE__), "hobo/static_tags")
                                end
                         File.readlines(path).*.chop
                       end
    end

    attr_writer :static_tags
    
    
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
      require 'hobo/dryml'
      require 'hobo/dryml/template'
      require 'hobo/dryml/dryml_generator'

      Hobo::Model.enable
      Hobo::Dryml.enable
      Hobo::Permissions.enable
      Hobo::ViewHints.enable
      
      Hobo.developer_features = RAILS_ENV.in?(["development", "test"]) if Hobo.developer_features?.nil?

      require 'hobo/dev_controller' if RAILS_ENV == Hobo.developer_features?

      ActionController::Base.send(:include, Hobo::ControllerExtensions)

      if defined? HoboFields
        HoboFields.never_wrap(Hobo::Undefined)
      end      

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
    group_by_without_metadata(&block).each do |k,v|
      v.origin = origin
      v.origin_attribute = origin_attribute
      v.member_class = member_class
    end
  end
  alias_method_chain :group_by, :metadata
end

Hobo.enable if defined?(Rails)

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# gem dependencies
require 'hobosupport'
require 'hobofields'
begin
  require 'will_paginate'
rescue MissingSourceFile
  # OK, Hobo won't do pagination then
end
require "active_record"
require "action_controller"
require "action_view"

# Monkey patches, ooh ooh
require 'active_record/has_many_association'
require 'active_record/has_many_through_association'
require 'active_record/association_proxy'
require 'active_record/association_reflection'
require 'action_view_extensions/base'

class HoboError < RuntimeError; end

module Hobo

  VERSION = "0.7.5"

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


    def user_model=(model)
      @user_model = model && model.name
    end


    def user_model
      @user_model && @user_model.constantize
    end


    def models=(models)
      @models = models.*.name
    end


    def models
      unless @models_loaded
        Dir.entries("#{RAILS_ROOT}/app/models/").each do |f|
          f =~ /^[a-zA-Z_][a-zA-Z0-9_]*\.rb$/ and f.sub(/.rb$/, '').camelize.constantize
        end
        @models_loaded = true
      end
      @models.*.constantize
    end


    def register_model(model)
      @models << model.name unless @models.include? model.name
    end


    def object_from_dom_id(dom_id)
      return nil if dom_id == 'nil'

      _, name, id, attr = *dom_id.match(/^([a-z_]+)(?:_([0-9]+(?:_[0-9]+)*))?(?:_([a-z_]+))?$/)
      raise ArgumentError.new("invalid model-reference in dom id") unless name
      if name
        model_class = name.camelize.constantize rescue (raise ArgumentError.new("no such class in dom-id"))
        return nil unless model_class

        if id
          obj = if false and attr and model_class.reflections[attr.to_sym].klass.superclass == ActiveRecord::Base
                  # DISABLED - Eager loading is broken - doesn't support ordering
                  # http://dev.rubyonrails.org/ticket/3438
                  # Don't do this for STI subclasses - it breaks!
                  model_class.find(id, :include => attr)
                else
                  model_class.find(id)
                end
          attr ? obj.send(attr) : obj
        else
          model_class
        end
      end
    end

    def dom_id(obj, attr=nil)
      attr ? "#{obj.typed_id}_#{attr}" : obj.typed_id
    end

    def find_by_search(query, search_targets=nil)
      search_targets ||=
        begin
          # FIXME: This should interrogate the model-router directly, there's no need to enumerate models
          # By default, search all models, but filter out...
          Hobo.models.select do |m|
          ModelRouter.linkable?(m, :show) && # ...non-linkables
            m.search_columns.any?             # and models with no search-columns
          end
        end

      query_words = ActiveRecord::Base.connection.quote_string(query).split

      search_targets.build_hash do |search_target|
        conditions = query_words.map do |word|
          "(" + search_target.search_columns.map { |column| %(#{column} like "%#{word}%") }.join(" or ") + ")"
        end.join(" and ")

        results = search_target.find(:all, :conditions => conditions)
        [search_target.name, results] unless results.empty?
      end
    end

    def add_routes(m)
      Hobo::ModelRouter.add_routes(m)
    end


    # FIXME: This method won't be needed
    def all_models
      Hobo.models.map { |m| m.name.underscore }
    end


    def simple_has_many_association?(array_or_reflection)
      refl = array_or_reflection.respond_to?(:proxy_reflection) ? array_or_reflection.proxy_reflection : array_or_reflection
      return false unless refl.is_a?(ActiveRecord::Reflection::AssociationReflection)
      refl.macro == :has_many and
        (not refl.through_reflection) and
        (not refl.options[:conditions])
    end


    def can_create_in_association?(array_or_reflection)
      refl =
        (array_or_reflection.is_a?(ActiveRecord::Reflection::AssociationReflection) and array_or_reflection) or
        array_or_reflection.try.proxy_reflection or
        (origin = array_or_reflection.try.origin and origin.send(array_or_reflection.origin_attribute).try.proxy_reflection)

      refl && refl.macro == :has_many && (!refl.through_reflection) && (!refl.options[:conditions])
    end


    def get_field(object, field)
      return nil if object.nil?
      if field.to_s =~ /^\d+$/
        object[field.to_i]
      else
        object.send(field)
      end
    end


    def get_field_path(object, path)
      path = if path.is_a? Array
               path
             elsif path.is_a? String
               path.split('.')
             else
               [path]
             end

      field, parent = nil
      path.each do |field|
        return nil if object.nil?
        parent = object
        object = get_field(parent, field)
      end
      [parent, field, object]
    end


    # --- Permissions --- #


    def can_create?(person, object)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
        object.set_creator(person)
      elsif (refl = object.try.proxy_reflection) && refl.macro == :has_many
        if Hobo.simple_has_many_association?(object)
          object = object.new
          object.set_creator(person)
        else
          return false
        end
      end
      check_permission(:create, person, object)
    end


    def can_update?(person, object, new)
      check_permission(:update, person, object, new)
    end


    def can_edit?(person, object, field)
      return true if object.exempt_from_edit_checks?
      # Can't view implies can't edit
      return false if !can_view?(person, object, field)

      if field.nil?
        if object.has_hobo_method?(:editable_by?)
          object.editable_by?(person)
        elsif object.has_hobo_method?(:updatable_by?)
          object.updatable_by?(person, nil)
        else
          false
        end

      else
        setter = "#{field.to_s.sub /\?$/, ''}="
        return false if !object.respond_to?(setter)

        refl = object.class.reflections[field.to_sym] if object.is_a?(ActiveRecord::Base)

        # has_one and polymorphic associations are not editable (for now)
        return false if refl and (refl.options[:polymorphic] or refl.macro == :has_one)

        if object.has_hobo_method?("#{field}_editable_by?")
          object.send("#{field}_editable_by?", person)
        elsif object.has_hobo_method?(:editable_by?)
          check_permission(:edit, person, object)
        elsif refl._?.macro == :has_many
          # The below technique to figure out edit permission based on
          # update permission doesn't work for has_many associations
          false
        else
          # Fake an edit test by setting the field in question to
          # Hobo::Undefined and then testing for update permission
          current = object.send(field)
          new = object.duplicate

          begin
            # Setting the undefined value can sometimes result in an
            # UndefinedAccessError. In that case we have no choice but
            # return false.
            new.send(setter, if current == true
                               false
                             elsif current == false
                               true
                             elsif refl and refl.macro == :belongs_to
                               Hobo::Undefined.new(refl.klass)
                             else
                               Hobo::Undefined.new
                             end)
          rescue Hobo::UndefinedAccessError
            raise HoboError, ("#{object.class.name}##{field} does not support undefined assignements, " +
                              "define #{field}_editable_by?(user)")
          end

          begin
            if object.new_record?
              check_permission(:create, person, new)
            else
              check_permission(:update, person, object, new)
            end
          rescue Hobo::UndefinedAccessError
            false
          end
        end
      end
    end


    def can_delete?(person, object)
      check_permission(:delete, person, object)
    end


    # can_view? has special behaviour if it's passed a class or an
    # association-proxy -- it instantiates the class, or creates a new
    # instance "in" the association, and tests the permission of this
    # object. This means the permission methods in models can't rely
    # on the instance being properly initialised.  But it's important
    # that it works like this because, in the case of an association
    # proxy, we don't want to loose the information that the object
    # belongs_to the proxy owner.
    def can_view?(person, object, field=nil)
      # Field can be a dot separated path
      if field && field.is_a?(String) && (path = field.split(".")).length > 1
        _, _, object = get_field_path(object, path[0..-2])
        field = path.last
      end

      if field
        field = field.to_sym if field.is_a? String
        return false if object.class.respond_to?(:never_show?) && object.class.never_show?(field)
      else
        # Special support for classes (can view instances?)
        if object.is_a?(Class) and object < Hobo::Model
          object = object.new
        elsif Hobo.simple_has_many_association?(object)
          object = object.new
        end
      end
      viewable = check_permission(:view, person, object, field)
      if viewable and field and
          ( (field_val = get_field(object, field)).is_a?(Hobo::Model) or field_val.is_a?(Array) )
        # also ask the current value if it is viewable
        can_view?(person, field_val)
      else
        viewable
      end
    end


    def can_call?(person, object, method)
      return true if person.has_hobo_method?(:super_user?) && person.super_user?

      m = "#{method}_callable_by?"
      object.has_hobo_method?(m) && object.send(m, person)
    end

    # --- end permissions -- #


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


    private


    def check_permission(permission, person, object, *args)
      return true if person.has_hobo_method?(:super_user?) and person.super_user?

      return true if permission == :view && !(object.is_a?(ActiveRecord::Base) || object.is_a?(Hobo::CompositeModel))

      obj_method = case permission
                   when :create; :creatable_by?
                   when :update; :updatable_by?
                   when :delete; :deletable_by?
                   when :edit;   :editable_by?
                   when :view;   :viewable_by?
                   end
      p = if (obj_method.respond_to?(:has_hobo_method) ? object.has_hobo_method?(obj_method) : object.respond_to?(obj_method))
            begin
              object.send(obj_method, person, *args)
            rescue Hobo::UndefinedAccessError
              false
            end
          elsif object.class.respond_to?(obj_method)
            object.class.send(obj_method, person, *args)
          elsif !object.is_a?(Class) # No user fallback for class-level permissions
            person_method = "can_#{permission}?".to_sym
            if person.has_hobo_method?(person_method)
              person.send(person_method, object, *args)
            else
              # The object does not define permissions - you can only view it
              permission == :view
            end
          end
    end

  end


end

require 'hobo/hobo_helper'
require 'hobo/scopes'
require 'hobo/undefined'
require 'hobo/undefined_access_error'
require 'hobo/authentication_support'

require 'hobo/model'
require 'hobo/controller'

require 'hobo/model_controller'
require 'hobo/model_router'
require 'hobo/model_support'
require 'hobo/composite_model'

require 'hobo/user'
require 'hobo/guest'

require 'hobo/dryml'
require 'hobo/rapid_helper'

require 'extensions/test_case' if RAILS_ENV == "test"

# Hobo can be installed in /vendor/hobo, /vendor/plugins/hobo, vendor/plugins/hobo/hobo, etc.
::HOBO_ROOT = File.dirname(__FILE__) + "/.."

ActionView::Base.register_template_handler("dryml", Hobo::Dryml::TemplateHandler)
# TODO - Rails 2.1 requires ActionView::Template
# ActionView::Template.register_template_handler("dryml", Hobo::Dryml::TemplateHandler)

class ActionController::Base

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

require 'hobo/dev_controller'
require 'hobo/user_controller'


class ActiveRecord::Base
  def self.hobo_model
    include Hobo::Model
    fields # force hobofields to load
  end
  def self.hobo_user_model
    include Hobo::Model
    include Hobo::User
  end
end


# Default settings

Hobo.developer_features = RAILS_ENV.in?(["development", "test"]) if Hobo.developer_features?.nil?


module ::Hobo
  # Empty class to represent the boolean type.
  class Boolean; end
end


if defined? HoboFields
  HoboFields.never_wrap(Hobo::Undefined)
end


# Add support for type metadata to arrays
class ::Array

  attr_accessor :member_class, :origin, :origin_attribute

  def to_url_path
    base_path = origin_object.try.to_url_path
    "#{base_path}/#{origin_attribute}" unless base_path.blank?
  end

  def typed_id
    origin_id = origin.try.typed_id
    "#{origin_id}_#{origin_attribute}" if origin_id
  end

end


class NilClass
  def typed_id
    "nil"
  end
end

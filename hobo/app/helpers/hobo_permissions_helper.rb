module HoboPermissionsHelper
  extend HoboHelperBase
  protected

    def current_user
      # simple one-hit-per-request cache
      @current_user ||= begin
                          id = session._?[:user]
                          (id && Hobo::Model.find_by_typed_id(id) rescue nil) || ::Guest.new
                        end
    end


    def logged_in?
      !current_user.guest?
    end


    def can_create?(object=this)
      if object.is_a?(Class) and object < ActiveRecord::Base
        object = object.new
      elsif (refl = object.try.proxy_association._?.reflection) && refl.macro == :has_many
        if Hobo.simple_has_many_association?(object)
          object = object.build
          object.set_creator(current_user)
        else
          return false
        end
      end
      object.creatable_by?(current_user)
    end


    def can_update?(object=this)
      object.updatable_by?(current_user)
    end


    def can_edit?(*args)
      object, field = if args.empty?
                        if !this.respond_to?(:to_a) && this.respond_to?(:editable_by?) && !this_field_reflection
                          [this, nil]
                        elsif this_parent && this_field
                          [this_parent, this_field]
                        else
                          [this, nil]
                        end
                      elsif args.length == 2
                        args
                      else
                        [this, args.first]
                      end

      if !field && (origin = object.try.origin)
        object, field = origin, object.origin_attribute
      end

      object.editable_by?(current_user, field)
    end


    def can_delete?(object=this)
      object.destroyable_by?(current_user)
    end



    def can_call?(*args)
      method = args.last
      object = args.length == 2 ? args.first : this

      object.method_callable_by?(current_user, method)
    end


    # can_view? has special behaviour if it's passed a class or an
    # association-proxy -- it instantiates the class, or creates a new
    # instance "in" the association, and tests the permission of this
    # object. This means the permission methods in models can't rely
    # on the instance being properly initialised.  But it's important
    # that it works like this because, in the case of an association
    # proxy, we don't want to loose the information that the object
    # belongs_to the proxy owner.
    def can_view?(*args)
      # TODO: Man does this need a big cleanup!

      if args.empty?
        # if we're repeating over an array, this_field ends up with the current index. Is this useful to anybody?
        if this_parent && this_field && !this_field.is_a?(Integer)
          object = this_parent
          field = this_field
        else
          object = this
        end
      elsif args.first.is_one_of?(String, Symbol)
        object = this
        field  = args.first
      else
        object, field = args
      end

      if field
        # Field can be a dot separated path
        if field.is_a?(String) && (path = field.split(".")).length > 1
          _, _, object = Dryml.get_field_path(object, path[0..-2])
          field = path.last
        end
      elsif (origin = object.try.origin)
        object, field = origin, object.origin_attribute
      end

      @can_view_cache ||= {}
      @can_view_cache[ [object, field] ] ||=
        if !object.respond_to?(:viewable_by?)
          true
        elsif object.viewable_by?(current_user, field)
          # If possible, we also check if the current *value* of the field is viewable
          if field.is_one_of?(Symbol, String) && (v = object.send(field)) && v.respond_to?(:viewable_by?)
            if v.is_a?(Array)
              v.new_candidate.viewable_by?(current_user, nil)
            else
              v.viewable_by?(current_user, nil)
            end
          else
            true
          end
        else
          false
        end
    end


    def select_viewable(collection=this)
      collection.select {|x| can_view?(x)}
    end
end

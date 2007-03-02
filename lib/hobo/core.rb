module Hobo

  module Core

    include Hobo::DefineTags

    include Hobo::ControllerHelpers

    def debug(x)
      logger.debug("\n############")
      logger.debug("DRYML DEBUG: " + x.inspect)
      logger.debug("DRYML THIS = " + Hobo.dom_id(this))
      logger.debug("############\n")
      x
    end


    def add_classes!(options, *classes)
      options[:class] = ([options[:class]] + classes).select{|x|x}.join(' ')
      options
    end


    def add_classes(options, *classes)
      options.merge(:class => ([options[:class]] + classes).select{|x|x}.join(' '))
    end
    
    
    def map_this
      res = []
      this.each_index {|i| new_field_context(i) { res << yield } }
      res
    end
    alias_method :collect_this, :map_this


    def comma_split(x)
      case x
      when nil
        []
      when Symbol
        x.to_s
      when String
        x.split(/\s*,\s*/)
      else
        x.map{|e| comma_split(e)}.flatten
      end
    end


    def can_create?(object)
      Hobo.can_create?(current_user, object)
    end


    def can_update?(object, new)
      Hobo.can_update?(current_user, object, new)
    end


    def can_edit?(object, field)
      if !field and object.respond_to?(:proxy_reflection)
        Hobo.can_edit?(current_user, object.proxy_owner, object.proxy_reflection.name)
      else
        Hobo.can_edit?(current_user, object, field)
      end
    end


    def can_edit_this?
      this_parent && this_field && can_edit?(this_parent, this_field)
    end


    def can_delete?(object)
      Hobo.can_delete?(current_user, object)
    end


    def can_view?(object, field=nil)
      if !field and object.respond_to?(:proxy_reflection)
        Hobo.can_view?(current_user, object.proxy_owner, object.proxy_reflection.name)
      else
        Hobo.can_view?(current_user, object, field)
      end
    end


    def can_view_this?
      if this_parent && this_field
        can_view?(this_parent, this_field)
      else
        can_view?(this)
      end
    end
    
    
    def viewable(collection)
      collection.select {|x| can_view?(x)}
    end


    def logged_in?
      not current_user.guest?
    end


    def theme_asset(path)
      "#{urlb}/hobothemes/#{Hobo.current_theme}/#{path}"
    end
    
    
    def_tag :dynamic_tag, :name do
      send(name, options)
    end

    
    def_tag :display_name do
      name_tag = "display_name_for_#{this.class.name.underscore}"
      if respond_to?(name_tag)
        send(name_tag)
      elsif this.is_a? Array
        "(#{count})"
      elsif this.is_a? Class and this < ActiveRecord::Base
        this.name.pluralize.titleize
      else
        res = [:display_name, :name, :title].search do |m|
          show(:attr => m) if this.respond_to?(m) and can_view?(this, m)
        end
        res || "#{this.class.name.humanize} #{this.id}"
      end
    end


    def_tag :object_link, :view, :to, :params do
      target = to || this
      if target.nil?
        "(Not Available)"
      elsif to ? can_view?(to) : can_view_this?
        content = tagbody ? tagbody.call : display_name
        link_to content, object_url(target, view, params), options
      end
    end


    def_tag :new_object_link, :for do
      f = for_ || this
      new = f.new
      new.created_by(current_user)
      if can_create?(new)
        default = "New " + (f.is_a?(Array) ? f.proxy_reflection.klass.name : f.name).titleize
        content = tagbody ? tagbody.call : default
        link_to content, object_url(f, "new")
      end
    end


    def_tag :tag_for_object, :name do
      opts = {}.update(options)
      opts.delete(:name)

      if this_type and m = "#{name}_for_#{this_type.name.underscore}" and respond_to?(m)
        send(m, opts)
      else
        send(name, opts)
      end
    end


    def_tag :show, :no_span do
      raise HoboError.new("attempted to show non-viewable field '#{this_field}'") unless can_view_this?
      
      type = this_type || this.class
      type = :string if type == String
      type = :integer if type == Fixnum
      type = :date if type == Date
      if this.nil?
        case type
          when  :string, :text; ""
          else; "(Not Available)"
        end
      elsif this_type.respond_to?(:macro)
        if this_type.macro == :belongs_to
          object_link
        elsif this_type.macro == :has_many
          if this.empty?
            "(none)"
          else
            map_this { object_link }.join(", ")
          end
        end
      else
        res = case type
              when :date
                if respond_to?(:show_date)
                  show_date
                else
                  this.to_s
                end
               
              when :datetime
                if respond_to?(:show_datetime)
                  show_datetime
                else
                  this.to_s
                end
                
              when :integer, :float, :decimal, :string, :text
                h(this).gsub("\n", "<br/>")
               
              when :html
                this
               
              when :markdown
                markdown(this)
               
              when :textile
                textilize(this)
               
              when :boolean
                this ? "Yes" : "No"
               
              else
                raise HoboError, "Cannot show: #{this.inspect} (field is #{this_field}, type is #{this_type.inspect})"
              end
        no_span ? res : "<span hobo_model_id='#{this_field_dom_id}'>#{res}</span>"
      end
    end


    def js_str(s)
      if s.is_a? Hobo::RawJs
        s.to_s
      else
        "'" + s.gsub("'"){"\\'"} + "'"
      end
    end


    def make_params_js(*args)
      ("'" + make_params(*args) + "'").sub(/ \+ ''$/,'')
    end


    def render_params(*args)
      parts = args.map{|x| x.split(/, */) if x}.compact.flatten
      {
        :part_page => view_name,
        :render => parts.map do |part_id|
          { :object => Hobo::RawJs.new("hoboParts.#{part_id}"),
            :part => part_id }
        end
      }
    end


    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end


    def xattrs(options, klass=nil)
      options ||= {}
      if klass
        options = options.symbolize_keys
        options[:class] = options[:class] ? (klass + ' ' + options[:class]) : klass
      end
      options.map do |n,v|
        v = v.to_s
        val = v.include?("'") ? '"' + v + '"' : "'" + v + "'"
        "#{n}=#{val}"
      end.join(' ')
    end


    def param_name_for(object, field_path)
      attrs = field_path.map{|part| "[#{part}]"}.join
      "#{object.class.name.underscore}#{attrs}"
    end

    
    def param_name_for_this(association_foreign_key=false)
      return "" unless form_this
      name = if association_foreign_key and this_type.respond_to?(:macro) and this_type.macro == :belongs_to
               param_name_for(form_this, form_field_path[0..-2] + [this_type.primary_key_name])
             else
               param_name_for(form_this, form_field_path)
             end
      register_form_field(name)
      name
    end
    
    
    def selector_type
      if this.is_a? ActiveRecord::Base
        this.class
      elsif this.respond_to? :member_class
        this.member_class
      elsif this == @this
        @model
      end
    end
    
    
    def_tag :human_type, :style do
      if can_view_this?
        res = if this.is_a? Array
                this.proxy_reflection.klass.name.pluralize
              elsif this.is_a? Class
                this.name
              else
                this.class.name
              end
        res.underscore.humanize.send(style || :titleize)
      end
    end


    def_tag :partial, :as do
      render(:partial => find_partial(this, as), :locals => { :this => this })
    end


    def_tag :repeat, :even_odd, :else do
      if this.empty?
        else_
      else
        if even_odd
          map_this do
            klass = [options[:class], cycle("even", "odd")].compact.join(' ')
            content_tag(even_odd, tagbody.call, options.merge(:class => klass, :hobo_model_id => dom_id(this)))
          end
        else
          map_this { tagbody.call }
        end
      end
    end


    def_tag :count, :label, :prefix do
      raise Exception.new("asked for count of a string") if this.is_a?(String)

      l = label
      if this.is_a?(Class) and this < ActiveRecord::Base
        c = this.count
        l ||= this.name.titleize
      else
        unless label
          assoc_name = this.proxy_reflection.name.to_s
          l = assoc_name.singularize.titleize
        end
        c = this.size
      end

      main = l.blank? ? c : pluralize(c, l)

      if prefix == "are"
        p = c == 1 ? "is" : "are"
        p + ' ' + main
      else
        main
      end
    end


    def_tag :with  do
      tagbody.call
    end


    def_tag :join, :with do
      map_this { tagbody.call }.join(with)
    end


    def_tag :link_tag, :href, :controller, :action, :id do
      link_to(tagbody.call, href ? href : { :controller => controller, :action => action, :id => id })
    end


    def_tag :if, :q do
      res = q ? tagbody.call : ""
      Dryml.last_if = q
      res
    end


    def_tag :else do
      tagbody.call unless Dryml.last_if
    end


    def_tag :unless, :q do
      if_(:q => !q) { tagbody.call }
    end
    
    
    def_tag :unless_blank do
      if_(:q => !this.blank?) { tagbody.call }
    end


    def_tag :if_empty do
      if_(:q => this.empty?) { tagbody.call }
    end
    

    def_tag :unless_empty do
      if_(:q => !this.empty?) { tagbody.call }
    end


    def_tag :if_this do
      if_(:q => this) { tagbody.call }
    end


    def_tag :if_can_delete do
      if_(:q => can_delete?(this)) { tagbody.call }
    end


    def_tag :if_can_create do
      if_(:q => can_create?(this)) { tagbody.call }
    end
    

    def_tag :if_can_view do
      if_(:q => can_view?(this)) { tagbody.call }
    end

    def_tag :if_can_edit do
      if_(:q => can_edit_this?) { tagbody.call }
    end
    
  end
end

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


    def add_classes(options, *classes)
      options[:class] = ([options[:class]] + classes).select{|x|x}.join(' ')
      options
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


    def can_update?(object, changes)
      Hobo.can_update?(current_user, object)
    end


    def can_edit?(object, field)
      Hobo.can_edit?(current_user, object, field)
    end


    def can_edit_this?
      this_parent && this_field && can_edit?(this_parent, this_field)
    end


    def can_delete?(object)
      Hobo.can_delete?(current_user, object)
    end


    def can_view?(object, field=nil)
      Hobo.can_view?(current_user, object, field)
    end


    def can_view_this?
      if this.is_a? ActiveRecord::Base
        can_view?(this)
      else
        raise HoboError.new("cannot check view permission -- no field-name for context") unless
          this_parent && this_field
        can_view?(this_parent, this_field)
      end
    end


    def logged_in?
      current_user != Hobo.guest_user
    end


    def theme_asset(path)
      "#{urlb}/hobothemes/#{Hobo.current_theme}/#{path}"
    end


    def_tag :tag_for_object, :name do
      opts = {}.update(options)
      opts.delete(:name)

      m  = "#{name}_for_#{this_type}"
      if respond_to?(m)
        send(m, opts)
      else
        send(name, opts)
      end
    end


    def_tag :show do
      raise HoboError.new("attempted to show non-viewable field") unless can_view_this?

      if this.nil?
        "(Not Available)"
      elsif this_type.respond_to?(:macro)
        if this_type.macro == :belongs_to
          object_link
        else
          map_this { object_link }.join(", ")
        end
      else
        case this_type
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

        when :text
          h(this).gsub("\n", "<br/>")

        when :string
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
          raise HoboError.new("Cannot show: #{this.inspect} (field is #{this_field})")
        end
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
      if association_foreign_key and this_type.respond_to?(:macro) and this_type.macro == :belongs_to
        param_name_for(form_this, form_field_path[0..-2] + [this_type.primary_key_name])
      else
        param_name_for(form_this, form_field_path)
      end
    end

    def_tag :human_type do
      c = this.is_a?(Class) ? this : this.class
      c.name.titleize
    end


    def_tag :partial, :as do
      render(:partial => find_partial(this, as), :locals => { :this => this })
    end


    def_tag :repeat, :even_odd do
      if even_odd
        map_this do
          klass = [options[:class], cycle("even", "odd")].compact.join(' ')
          content_tag(even_odd, tagbody.call, options.merge(:class => klass))
        end
      else
        map_this { tagbody.call }
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


    def_tag :if_empty do
      if_(:q => this.empty?) { tagbody.call }
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

  end
end

module Hobo

  module Core

    include Hobo::DefineTags

    include Hobo::ControllerHelpers

    def debug(*args)
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.map {|a| PP.pp(a, "")}.join("-------\n"))
      logger.debug("DRYML THIS = " + Hobo.dom_id(this).to_s)
      logger.debug("###################\n")
      args.first unless args.empty?
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


    def theme_asset(path)
      "#{urlb}/hobothemes/#{Hobo.current_theme}/#{path}"
    end
    
    
    def_tag :call_tag, :name do
      send(name, options)
    end

    
    def_tag :display_name do
      if this.nil?
        "(not available)"
      else
        name_tag = "display_name_for_#{this.class.name.underscore}"
        if respond_to?(name_tag)
          send(name_tag)
        elsif this.is_a?(Array) && this.respond_to?(:proxy_reflection)
          "(#{count})"
        elsif this.is_a? Class and this < ActiveRecord::Base
          this.name.pluralize.titleize
        else
          res = [:display_name, :name, :title].search do |m|
            show(options.merge(:field => m)) if this.respond_to?(m) and can_view?(this, m)
          end
          res || "#{this.class.name.humanize} #{this.id}"
        end
      end
    end


    def_tag :object_link, :view, :to, :params do
      target = to || this
      if target.nil?
        "(Not Available)"
      elsif to ? can_view?(to) : can_view_this?
        content = tagbody ? tagbody.call : display_name
        link_class = "#{target.class.name.underscore}_link"
        link_to content, object_url(target, view, params), add_classes(options, link_class)
      end
    end


    def_tag :new_object_link, :for do
      f = for_ || this
      new = f.respond_to?(:new_without_appending) ? f.new_without_appending : f.new
      new.set_creator(current_user) if new.respond_to?(:current_user)
      if can_create?(new)
        default = "New " + (f.is_a?(Array) ? f.proxy_reflection.klass.name : f.name).titleize
        content = tagbody ? tagbody.call : default
        link_class = "new_#{new.class.name.underscore}_link"
        link_to content, object_url(f, "new"), add_classes(options, link_class)
      end
    end


    def_tag :show, :no_wrapper, :truncate_tail, :format do
      # We can't do this as a declared attribute as it will hide the truncate helper
      trunc = options.delete(:truncate)
      
      raise HoboError, "show of non-viewable field '#{this_field}' of #{this_parent.typed_id rescue this_parent}" unless
        can_view_this?
      
      res = if this_type.respond_to?(:macro)
              if this_type.macro == :belongs_to
                show_belongs_to
              elsif this_type.macro == :has_many
                show_has_many
              end
              
            else
              res2 = case this
                     when nil
                       this_type <= String ? "" : "(Not Available)"
                       
                     when Date
                       if respond_to?(:show_date)
                         show_date
                       else
                         this.to_s(:long)
                       end
                       
                     when Time
                       if respond_to?(:show_datetime)
                         show_datetime
                       else
                         this.to_s(:long)
                       end
                       
                     when Numeric
                       format ? format % this : this.to_s
                       
                     when Hobo::HtmlString
                       this
                       
                     when Hobo::MarkdownString
                       markdown(this)
                       
                     when Hobo::TextileString
                       textilize(this)
                       
                     when Hobo::PasswordString
                       "[password withheld]"
                       
                     when String
                       h(this).gsub("\n", "<br/>")
                       
                     when TrueClass
                       "Yes"
                       
                     when FalseClass
                       "No"
                       
                     else
                       raise HoboError, "Cannot show: #{this.inspect} (field is #{this_field}, type is #{this.class})"
                     end
              tag = case this
                    when Hobo::Text, Hobo::HtmlString, Hobo::MarkdownString, Hobo::TextileString
                      :div
                    else
                      :span
                    end
              
              if !no_wrapper && this_parent.respond_to?(:typed_id)
                content_tag tag, res2, options.merge(:hobo_model_id => this_field_dom_id)
              else
                res2
              end
            end
      trunc ? truncate(res2, trunc.to_i, truncate_tail || "...") : res
    end
    
    
    def_tag :show_belongs_to do
      object_link
    end
    
    
    def_tag :show_has_many do
      if this.empty?
        "(none)"
      else
        map_this { object_link }.join(", ")
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
      { :part_page => view_name,
        :render => parts.map do |part_id|
          { :object => Hobo::RawJs.new("hoboParts.#{part_id}"),
            :part => part_id }
        end
      }
    end


    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end


    def param_name_for(object, field_path)
      field_path = field_path.to_s.split(".") if field_path.is_a?(String, Symbol)
      attrs = field_path.map{|part| "[#{part.to_s.sub /\?$/, ''}]"}.join
      "#{object.class.name.underscore}#{attrs}"
    end

    
    def param_name_for_this(foreign_key=false)
      return "" unless form_this
      name = if foreign_key and this_type.respond_to?(:macro) and this_type.macro == :belongs_to
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
        res = if this.respond_to? :proxy_reflection
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


    def_tag :repeat, :even_odd do
      Dryml.last_if = !this.blank?
      if Dryml.last_if
        if even_odd
          map_this do
            klass = [options[:class], cycle("even", "odd")].compact.join(' ')
            content_tag(even_odd, tagbody.call, options.merge(:class => klass, :hobo_model_id => dom_id(this)))
          end
        else
          map_this { tagbody.call }
        end
      else
        ""
      end
    end

    
    def_tag :transpose_and_repeat, :with_field do
      matrix = this.map {|obj| obj.send(with_field) }
      max_length = matrix.omap{ length }.max
      matrix = matrix.map do |a|
        a + [nil] * (max_length - a.length)
      end
      repeat(:with => matrix.transpose) { tagbody.call }
    end


    def_tag :count, :label, :prefix, :unless_none do
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
        c = if this.is_a?(Fixnum)
              this
            elsif this.respond_to?(:count)
              this.count
            else 
              this.length
            end
      end

      Dryml.last_if = (c > 0 || unless_none.nil?)
      if Dryml.last_if        
        main = l.blank? ? c : pluralize(c, l)

        if prefix == "are"
          p = c == 1 ? "is" : "are"
          p + ' ' + main
        else
          main
        end
      else
        ""
      end
    end


    def_tag :with do
      tagbody.call
    end


    def_tag :join, :with do
      map_this { tagbody ? tagbody.call : display_name }.join(with)
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
    

    def_tag :if_blank do
      if_(:q => this.blank?) { tagbody.call }
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

module Hobo::Rapid

  include Hobo::DefineTags


  def options_for_hobo_ajax(options)
    js_options = build_callbacks(options)

    js_options['asynchronous']  = false if options[:type] == :synchronous
    js_options['method']        = method_option_to_s(options[:method]) if options[:method]
    js_options['evalScripts']   = false if options[:script] == false
    js_options['form']          = options[:form] if options[:form]
    js_options['params']        = make_params_js(options[:params]) if options[:params]
    js_options['resultUpdate'] = js_result_updates(options[:result_update]) if options[:result_update]

    js_options.empty? ? nil : options_for_javascript(js_options)
  end

  
  def js_updates(updates)
    return '[]' unless updates
    updates = [updates] unless updates.is_a? Array
    '[' + comma_split(updates).map{|u| js_str(u)}.join(', ') + ']'
  end
  
  
  def js_result_updates(updates)
    return '[]' unless updates
    updates = [updates] unless updates.is_a? Array
    pairs = comma_split(updates).omap{split(/\s*=\s*/)}
    '[' + pairs.map{|p| "[#{js_str(p[0])}, #{js_str(p[1])}]"}.join(", ") + ']'
  end


  def ajax_updater(url_or_form, message, update, options={})
    options ||= {}
    target = if url_or_form == :post_form
               target = "this"
             else
               js_str(url_or_form)
             end
    js_options = options_for_hobo_ajax(options)
    args = [target, js_str(message || "..."), js_updates(update), js_options].compact
    
    confirm = options.delete(:confirm)
    
    func = "Hobo.ajaxRequest(#{args * ', '})"
    if confirm
      "if (confirm(#{js_str(confirm)})) { #{func} }"
    else
      func
    end
  end


  def a_or_an(word)
    if word =~ /^[aeiouh]/
      "an #{word}"
    else
      "a #{word}"
    end
  end


  def no_break(s)
    s.gsub(' ', '&nbsp;')
  end


  def current_user_in?(collection)
    collection.member? current_user
  end


  def_tag :if_current_user_in do
    if_(:q => current_user_in?(this)) { tagbody.call }
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
        this.send(m) if this.respond_to?(m) and can_view?(this, m)
      end
      res || "#{this.class.name.humanize} #{this.id}"
    end
  end


  def_tag :object_link do
    if can_view_this?
      if this.nil?
        "(Not Available)"
      else
        raise HoboError.new("can't link to nil/false (\#<#{this.class}>.#{attr})") unless this
        v = this.is_a?(String) ? this.singularize.classify.constantize : this
        content = tagbody ? tagbody.call : display_name(:obj => v)
        link_to content, object_url(v), options
      end
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


  def_tag :edit, :in_place do
    if can_view_this?
      if not can_edit_this?
        show
      elsif this_parent.new_record? or in_place == false
        form_field(options)
      else
        editor(options)
      end
    end
  end


  def_tag :form_field do
    name = param_name_for_this
    raise HoboError.new("Not allowed to edit") unless can_edit_this?
    if this_type.respond_to?(:macro)
      if this_type.macro == :belongs_to
        belongs_to_menu_field(options)
      elsif this_type.macro == :has_many
        raise NotImplementedError.new("editor for has_many associations not implemented")
      end
      
    elsif this_type.in? [:integer, :float, :decimal, :string]
      tag :input, options.merge(:type => 'text', :name => name, :value => this)
      
    elsif this_type == :text
      content_tag :textarea, this, options.merge(:name => name)
      
    elsif this_type == :boolean
      check_box_tag(name, '1', this, options)
      
    elsif this_type == :date
      date_select "", this_field
      
    elsif this_type == :datetime
      select_datetime this, :prefix => name
      
    elsif this_type == :password
      password_field_tag(name, this)
      
    else
      raise HoboError.new("<form_edit> not implemented for #{this.class.name}\##{this_field} " +
                          "(#{this.inspect}:#{this_type})")
    end
  end


  def_tag :editor do
    raise HoboError.new("Not allowed to edit") unless can_edit_this?

    if this_type.respond_to?(:macro)
      if this_type.macro == :belongs_to
        belongs_to_editor(options)
      else
        # In place edit for has_many not implemented
        object_link(options)
      end
    elsif this_type.in? [:integer, :float, :decimal, :datetime,
                            :date, :timestamp, :time, :text, :string]
      disp = show
      disp = "(click to edit)" if disp.blank?

      class_ = [options[:class],
                "in_place_edit_bhv",
                ("textarea_editor" if this_type == :text)].compact.join(' ')

      content_tag(:span, disp, options.merge(:class => class_, :model_id => this_field_dom_id))
    elsif this_type == :boolean
      boolean_checkbox_editor(options)
    end
  end
  
  
  def_tag :belongs_to_editor do
    belongs_to_menu_editor
  end
  

  AJAX_ATTRS = [:before, :success, :failure, :complete, :type, :method, :script, :form, :params, :confirm]


  def_tag :update_button, :label, :message, :attrs, :update do
    raise HoboError.new("no update specified") unless update
    message2 = message || label
    func = ajax_updater(object_url(this), message2, update, :params => { this.class.name.underscore => attrs })
    tag :input, add_classes(options.merge(:type =>'button', :onclick => func, :value => label), "button_input")
  end


  def_tag :delete_button, :label, :message, :update, :ajax, :else do
    if can_delete?(this)
      lab = label || "Remove"
      url = object_url(this, "destroy")
      if ajax == false
        button_to label, url, add_classes(options, "button_input").merge(:confirm => "Are you sure?")
      else
        if update
          func = ajax_updater(url, message || "Removing", update)
        else
          func = "Hobo.removeButton(this, '#{url}')"
        end
        opts = add_classes(options.merge(:type => 'button', :onclick => func, :value => lab), "button_input")
        opts[:disabled] = true unless can_delete?(this)
        tag :input, opts
      end
    else
      else_
    end
  end
  
  
  def_tag :create_button, :model, :update, :attrs, :label, :message, :else do
    raise HoboError.new("no update specified") unless update
    params = attrs || {}
    if model
      new = (model.is_a?(String) ? model.constantize : model).new
    else
      raise HoboError.new("invalid context for <create_button>") unless Hobo.simple_has_many_association?(this)
      params[this.proxy_reflection.primary_key_name] = this.proxy_owner.id
      new = this.new
    end
    if can_create?(new)
      label2 = label || "New #{new.class.name.titleize}"
      message2 = message || label2
      func = ajax_updater(object_url(new.class), message2, update,
                          ({:params => { new.class.name.underscore => params }} unless params.empty?))
      tag :input, add_classes(options.merge(:type =>'button', :onclick => func, :value => label2), "button_input")
    else
      else_
    end
  end
  
  
  def_tag :remote_method_button, :method, :update, :result_update, :params, :label, :message do
    ajax_options, html_options = options.partition_hash(AJAX_ATTRS)

    message2 = message || method.titleize
    func = ajax_updater(object_url(this) + "/#{method}", message2, update,
                        ajax_options.merge(:params => params, :result_update => result_update))
    tag :input, add_classes(html_options.merge(:type =>'button', :onclick => func, :value => label), "button_input")
  end
  

  def_tag :hobo_rapid_javascripts do
    res = javascript_include_tag("hobo_rapid")
    res += "<script>"
    unless Hobo.all_controllers.empty?
      res += "var controllerNames = {" +
        Hobo.all_controllers.map {|c| "#{c.singularize}: '#{c}'"}.join(', ') +
        "}; "
    end
    res += "urlBase = '#{urlb}'; hoboPartPage = '#{view_name}'</script>"
    res
  end


  def_tag :object_form, :message, :update, :hidden_fields do
    ajax_options, html_options = options.partition_hash(AJAX_ATTRS)

    url = object_url(this)
    if update
      # add an onsubmit to convert to an ajax form if `update` is given
      function = ajax_updater(:post_form, message, update, ajax_options)
      html_options[:onsubmit] = [html_options[:onsubmit],
                                 "#{function}; return false;"].compact.join("; ")
    end

    hiddens = case hidden_fields
              when nil
                []
              when '*'
                this.class.column_names
              else
                comma_split(hidden_fields)
              end
    pname = this.class.name.underscore
    hidden_tags = hiddens.map do |h|
      val = this.send(h)
      hidden_field_tag("#{pname}[#{h}]", val.to_s) if val
    end
    hidden_tags << hidden_field_tag("_method", "PUT") unless this.new_record?

    html_options[:method] = "post"
    body = ( hidden_tags.compact.join("\n") +
             (tagbody ? with_form_context { tagbody.call } : "") )

    content_tag("form", body, html_options.merge(:action => url))
  end

  
  def_tag :create_form, :model, :in, :update, :message, :hidden_fields do
    hiddens = hidden_fields
    if model
      obj = (model.is_a?(String) ? model.constantize : model).new
    else
      raise HoboError.new("cannot create object in #{in_.inspect}") unless this.is_a? Array
      obj = this.new
      refl = this.proxy_reflection
      if refl.macro == :has_many and !refl.through_reflection
        hiddens ||= [refl.primary_key_name]
      end
    end
    m = message || "New #{obj.class.name.titleize}"
    object_form(obj, options.merge(:message => m, :update => update, :hidden_fields => hiddens)) do
      tagbody.call
    end
  end

end

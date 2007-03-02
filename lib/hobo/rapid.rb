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
    '[' + pairs.map{|p| "{id: #{js_str(p[0])}, result: #{js_str(p[1])}}"}.join(", ") + ']'
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
    s = new_context { yield } if block_given?
    s.gsub(' ', '&nbsp;')
  end


  def current_user_in?(collection)
    collection.member? current_user
  end


  def_tag :if_current_user_in do
    if_(:q => current_user_in?(this)) { tagbody.call }
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
    name = options[:name] || param_name_for_this
    raise HoboError.new("Not allowed to edit") unless can_edit_this?
    if this_type.respond_to?(:macro)
      if this_type.macro == :belongs_to
        belongs_to_menu_field(options)
      elsif this_type.macro == :has_many
        raise NotImplementedError.new("editor for has_many associations not implemented")
      end
      
    else
      case this_type
        when :integer, :float, :decimal, :string
        text_field_tag(name, this, options)
      
      when :text, :html
        text_area_tag(name, this, options)
      
      when :boolean
        check_box_tag(name, '1', this, options)
      
      when :date
        date_field(options)
      
      when :datetime
        datetime_field(options)
      
      when :password
        password_field_tag(name, this)
      
      else
        raise HoboError.new("<form_field> not implemented for #{this.class.name}\##{this_field} " +
                            "(#{this.inspect}:#{this_type})")
      end
    end
  end
  
  
  def_tag :date_field do
    select_date(this || Time.now, :prefix => param_name_for_this)
  end


  def_tag :datetime_field do
    select_datetime(this || Time.now, :prefix => param_name_for_this)
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
    else
      case this_type
      when :string
        text_field_editor(options)

      when :text
        text_area_editor(options)

      when :html
        html_editor(options)
        
      when :integer, :float, :decimal, :timestamp, :time, :date, :datetime
        if respond_to?("#{this_type}_editor")
          send("#{this_type}_editor", options)
        else
          text_field_editor(options)
        end
        
      when :datetime
        datetime_editor(options)
        
      when :date
        date_editor(options)
        
      when :boolean
        boolean_checkbox_editor(options)

      else
        raise HoboError.new("<editor> not implemented for #{this.class.name}\##{this_field} " +
                            "(#{this.inspect}:#{this_type})")
      end
    end
  end
  
  
  def in_place_editor(kind, options)
    disp = show(:no_span => true)
    disp = "(click to edit)" if disp.blank?
    opts = add_classes(options, kind).merge(:hobo_model_id => this_field_dom_id)
    update = opts.delete(:update)
    opts[:hobo_update] = update if update
    content_tag(:span, disp, opts)
  end
    
  
  def_tag :text_field_editor do
    in_place_editor "in_place_textfield_bhv", options
  end
  
  def_tag :text_area_editor do
    in_place_editor "in_place_textarea_bhv", options
  end
  
  
  def_tag :html_editor do
    in_place_editor "in_place_html_textarea_bhv", options
  end
  
  def_tag :belongs_to_editor do
    belongs_to_menu_editor(options)
  end
  
  
  def_tag :datetime_editor do
    text_field_editor(options)
  end
  
  
  def_tag :date_editor do
    text_field_editor(options)
  end
  

  AJAX_ATTRS = [:before, :success, :failure, :complete, :type, :method, :script, :form, :params, :confirm]


  def_tag :update_button, :label, :message, :attrs, :update, :params do
    raise HoboError.new("no update specified") unless update
    message2 = message || label
    func = ajax_updater(object_url(this), message2, update,
                        :params => { this.class.name.underscore => attrs }.merge(params),
                        :method => :put)
    tag :input, add_classes(options.merge(:type =>'button', :onclick => func, :value => label),
                            "button_input update_button")
  end


  def_tag :delete_button, :label, :message, :update, :ajax, :else, :image, :confirm do
    if can_delete?(this)
      opts = options.merge(if image
                             { :type => "image", :src => "#{urlb}/images/#{image}" }
                           else
                             { :type => "button" }
                           end)
      label2 = label || "Remove"
      confirm2 = confirm || "Are you sure?"
      
      add_classes!(opts, image ? "image_button_input" : "button_input", "delete_button")
      url = object_url(this, "destroy")
      if ajax == false
        opts[:confirm] = confirm2
        button_to(label2, url, opts)
      else
        opts[:value] = label2
        opts[:onclick] = "Hobo.removeButton(this, '#{url}', #{js_updates(update)})"
        tag(:input, opts)
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
      tag :input, add_classes(options.merge(:type =>'button', :onclick => func, :value => label2),
                              "button_input create_button")
    else
      else_
    end
  end
  
  
  def_tag :remote_method_button, :method, :update, :result_update, :params, :label, :message do
    ajax_options, html_options = options.partition_hash(AJAX_ATTRS)

    message2 = message || method.titleize
    func = ajax_updater(object_url(this) + "/#{method}", message2, update,
                        ajax_options.merge(:params => params, :result_update => result_update))
    tag :input, add_classes(html_options.merge(:type =>'button', :onclick => func, :value => label),
                            "button_input remote_method_button")
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

    url = options[:url] || object_url(this)
    if update
      # add an onsubmit to convert to an ajax form if `update` is given
      function = ajax_updater(:post_form, message, update, ajax_options)
      html_options[:onsubmit] = [html_options[:onsubmit],
                                 "#{function}; return false;"].compact.join("; ")
    end

    body, field_names = with_form_context{ tagbody.call }
    body = body.to_s

    hiddens = case hidden_fields
              when nil
                []
              when '*'
                this.class.column_names - ['type']
              else
                comma_split(hidden_fields)
              end
    pname = this.class.name.underscore
    hidden_tags = hiddens.map do |h|
      val = this.send(h)
      name = "#{pname}[#{h}]"
      hidden_field_tag(name, val.to_s) if val and name.not_in?(field_names)
    end
    hidden_tags << hidden_field_tag("_method", "PUT") unless this.respond_to?(:new_record?) and this.new_record?

    html_options[:method] = "post"
    body_with_hiddens = hidden_tags.compact.join("\n") + body
    content_tag("form", body_with_hiddens, html_options.merge(:action => url))
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

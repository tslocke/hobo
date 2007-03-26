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
  
  
  def type_name(klass)
    { Hobo::HtmlString     => :html,
      Hobo::Text           => :textarea,
      TrueClass            => :boolean,
      FalseClass           => :boolean,
      Date                 => :date,
      Time                 => :datetime,
      Hobo::PasswordString => :password_string,
      Fixnum               => :integer,
      BigDecimal           => :integer,
      Float                => :float,
      String               => :string }[klass]
  end


  def_tag :form_field do
    raise HoboError.new("Not allowed to edit") unless can_edit_this?
    if this_type.respond_to?(:macro)
      if this_type.macro == :belongs_to
        belongs_to_field(options)
      elsif this_type.macro == :has_many
        has_many_field(options)
      end
      
    else
      tag = type_name(this_type).to_s + "_field"
      if respond_to?(tag)
        options[:name] ||= param_name_for_this
        tag_src = send(tag, options)
        if this_parent.errors[this_field]
          "<div class='field_with_errors'>#{tag_src}</div>"
        else
          tag_src
        end
      else
        raise HoboError, ("No form field tag for #{this_field}:#{this_type} (this=#{this.inspect})")
      end
    end
  end
  
  def_tag :has_many_field do
    raise NotImplementedError, "form field for has_many associations not implemented"
  end
  
  def_tag :belongs_to_field do
    belongs_to_menu_field(options)
  end
  
  def_tag :textarea_field, :name do 
    text_area_tag(name, this, options)
  end
  
  
  def_tag :boolean_field, :name do
    check_box_tag(name, '1', this, options)
  end
  
  def_tag :password_string_field, :name do
    password_field_tag(name, this)
  end
  
  def_tag :html_field, :name do
    text_area_tag(name, this, add_classes(options, "tiny_mce"))
  end
  
  def_tag :date_field do
    select_date(this || Time.now, :prefix => param_name_for_this)
  end

  def_tag :datetime_field do
    select_datetime(this || Time.now, :prefix => param_name_for_this)
  end

  def_tag :integer_field, :name do
    text_field_tag(name, this, options)
  end

  def_tag :float_field, :name do
    text_field_tag(name, this, options)
  end

  def_tag :string_field, :name do
    text_field_tag(name, this, options)
  end

  def_tag :editor do
    raise HoboError.new("Not allowed to edit") unless can_edit_this?

    if this_type.respond_to?(:macro)
      if this_type.macro == :belongs_to
        belongs_to_editor(options)
      else
        has_many_editor(options)
      end
    else
      tag = type_name(this_type).to_s + "_editor"
      if respond_to?(tag)
        send(tag, options)
      else
        raise HoboError.new("<editor> not implemented for #{this.class.name}\##{this_field} " +
                            "(#{this.inspect}:#{this_type})")
      end
    end
  end
  
  
  def_tag :has_many_editor do
    # TODO: Implement
    object_link(options)
  end
  
  
  def in_place_editor(kind, options)
    opts = add_classes(options, kind).merge(:hobo_model_id => this_field_dom_id)

    update = opts.delete(:update)
    blank_message = opts.delete(:blank_message) || "(click to edit)"
    
    display = show(:no_span => true)
    opts[:hobo_blank_message] = blank_message
    display = blank_message if display.blank?
    opts[:hobo_update] = update if update 
    content_tag(:span, display, opts)
  end
    
  
  def_tag :string_editor do
    in_place_editor "in_place_textfield_bhv", options
  end
  
  def_tag :textarea_editor do
    in_place_editor "in_place_textarea_bhv", options
  end
    
  def_tag :html_editor do
    in_place_editor "in_place_html_textarea_bhv", options
  end
  
  def_tag :belongs_to_editor do
    belongs_to_menu_editor(options)
  end
  
  def_tag :datetime_editor do
    string_editor(options)
  end
  
  def_tag :date_editor do
    string_editor(options)
  end

  def_tag :integer_editor do
    in_place_editor "in_place_textfield_bhv", options
  end

  def_tag :float_editor do
    in_place_editor "in_place_textfield_bhv", options
  end

  def_tag :password_string_editor do
    raise HoboError, "passwords cannot be edited in place"
  end
  
  def_tag :boolean_editor do
    boolean_checkbox_editor(options)
  end
  

  AJAX_ATTRS = [:before, :success, :failure, :complete, :type, :method, :script, :form, :params, :confirm]


  def_tag :update_button, :label, :message, :attrs, :update, :params do
    raise HoboError.new("no update specified") unless update
    message2 = message || label
    func = ajax_updater(object_url(this), message2, update,
                        :params => { this.class.name.underscore => attrs }.merge(params || {}),
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
    tag :input, add_classes(html_options.merge(:type =>'button', :onclick => "var e = this; " + func, :value => label),
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


  def_tag :object_form, :message, :update, :hidden_fields, :url do
    ajax_options, html_options = options.partition_hash(AJAX_ATTRS)

    url2 = url || object_url(this)
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
    content_tag("form", body_with_hiddens, html_options.merge(:action => url2))
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
  
  def_tag :remote_method_form, :method, :message, :update do
    ajax_options, html_options = options.partition_hash(AJAX_ATTRS)
    
    url = object_url(this, method)
    if update || !ajax_options.empty?
      # add an onsubmit to convert to an ajax form
      function = ajax_updater(:post_form, message, update, ajax_options)
      html_options[:onsubmit] = [html_options[:onsubmit],
                                 "var e = this; #{function}; return false;"].compact.join("; ")
    end

    html_options[:method] = "post"
    content_tag("form", tagbody.call, html_options.merge(:action => url))
  end

end

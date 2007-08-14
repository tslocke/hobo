module Hobo::RapidHelper

  def options_for_hobo_ajax(options)
    js_options = build_callbacks(options)

    js_options['asynchronous']  = false if options[:type] == :synchronous
    js_options['method']        = method_option_to_s(options[:method]) if options[:method]
    js_options['evalScripts']   = false if options[:script] == false
    js_options['form']          = options[:form] if options[:form]
    js_options['params']        = make_params_js(options[:params]) if options[:params]
    js_options['resultUpdate']  = js_result_updates(options[:result_update]) if options[:result_update]
    js_options['resetForm']     = false if options[:reset_form] == false
    js_options['refocusForm']   = false if options[:refocus_form] == false
    
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



  
  def in_place_editor(kind, tag, options)
    opts = add_classes(options, kind, editor_class).merge(:hobo_model_id => this_field_dom_id)

    update = opts.delete(:update)
    blank_message = opts.delete(:blank_message) || "(click to edit)"
    
    display = show(:no_wrapper => true)
    opts[:hobo_blank_message] = blank_message
    display = blank_message if display.blank?
    opts[:hobo_update] = update if update 
    content_tag(tag, display, opts)
  end
    
  

  AJAX_ATTRS = [:before, :success, :failure, :complete, :type, :method,
                :script, :form, :params, :confirm,
                :reset_form, :refocus_form]


  def editor_class
    "#{this_parent.class.name.underscore}_#{this_field}_editor"
  end

end

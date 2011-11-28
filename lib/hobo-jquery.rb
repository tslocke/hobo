module HoboJquery
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  require 'hobo-jquery/railtie' if defined?(Rails)
end

Hobo::Rapid::Helper.module_eval do
  def ajax_updater(url_or_form, update, options={})
    debugger
  end

  # this function provides the meat for the form and formlet tags.  It
  # returns a tuple of:
  #   body: html body
  #   html_attrs:  class, id, etc.
  #   ajax_attrs:  update, spinner-next-to, etc
  #   form_attrs:  action, method, enctype
  def form_helper(attributes, parameters)
    attrs, other_attrs = attributes.partition_hash([:hidden_fields, :action, :method, :web_method, :lifecycle, :owner, :multipart])
    ajax_attrs, html_attrs = other_attrs.partition_hash(Hobo::Rapid::Helper::AJAX_ATTRS)
    form_attrs = {}

    form_attrs[:enctype] = html_attrs[:enctype] if html_attrs[:enctype]
    form_attrs[:enctype] ||= "multipart/form-data" if attrs[:multipart]

    new_record = this.try.new_record?

    method = if attrs[:method].nil?
               (attrs[:action] || attrs[:web_method] || new_record) ? "post" : "put"
             else
               attrs[:method].downcase
             end

    form_attrs[:action] = attrs[:action] ||
      begin
        target = if attrs[:owner]
                   collection_name = this.class.reverse_reflection(attrs[:owner]).name
                   this.send(attrs[:owner]).send(collection_name)
                 else
                   this
                 end
        attrs[:action] = attrs[:web_method] || attrs[:lifecycle]
        object_url(target, attrs[:action], :method => method)
      end

    if attrs[:action].nil? && (form_attrs[:action].nil? ||
                     (attrs[:lifecycle].nil? && new_record && !this.creatable_by?(current_user)) ||
                     (attrs[:lifecycle].nil? && !new_record && !can_edit?))
      Dryml.last_if = false
      logger.info("unable to render form")
      return nil
    else
      if method == "put"
        # browsers don't support put -- use post and add the Rails _method hack
        http_method_hidden = hidden_field_tag("_method", "PUT")
        form_attrs[:method] = "post"
      else
        http_method_hidden = ""
        form_attrs[:method] = method
      end

      hiddens = ""
      body = with_form_context do
        # It is important to evaluate parameters.default first, in order to populate scope.form_field_names
        b = parameters.default
        hiddens = self.hidden_fields(:fields => attrs[:hidden_fields]) if new_record
        b
      end

      auth_token = if method.nil? || method == 'get' || !protect_against_forgery?
                     ''
                   else
                     element(:input, {:type => "hidden",
                               :name => request_forgery_protection_token.to_s,
                               :value => form_authenticity_token}, nil, true, true)
                   end

      unless method == "get"
        page_path = if (request.post? || request.put?) && params[:page_path]
                      params[:page_path]
                    else
                      request.fullpath
                    end
        page_path_hidden = hidden_field_tag("page_path", page_path)
      end

      hiddens_div = element(:div, {:class => "hidden-fields"}, [http_method_hidden, page_path_hidden, auth_token, hiddens].safe_join)

      body = [hiddens_div, body].safe_join

      if attrs[:action].nil? # don't add automatic css classes if the action was specified
        if attrs[:web_method]
          add_classes!(html_attrs, "#{type_id.dasherize}-#{web_method}-form")
        else
          add_classes!(html_attrs, "#{'new ' if new_record}#{type_id.dasherize}")
        end
        unless ajax_attrs.blank?
          add_classes!(html_attrs, 'rapid-annotated')
        end
      end

      Dryml.last_if = true
      [body, html_attrs, ajax_attrs, form_attrs]
    end
  end

  def data_rapid(tag, options = {})
    {tag => options}.to_json
  end

end

Dryml::PartContext.module_eval do
  def self.client_side_storage_uncoded(contexts, session)
    contexts.inject({}) do |h, (dom_id, context)|
      h[dom_id] = context.marshal(session)
      h
    end
  end
end

Dryml::TemplateEnvironment.module_eval do
  def part_contexts_storage_uncoded
    Dryml::PartContext.client_side_storage_uncoded(@_part_contexts, session)
  end
end

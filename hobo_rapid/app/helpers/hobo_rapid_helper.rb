module HoboRapidHelper
    AJAX_CALLBACKS = [ :success, :failure, :complete, :before ]

    AJAX_UPDATE_ATTRS = [  :update, :updates, :ajax ]

    AJAX_EFFECT_ATTRS = [ :hide, :show ]

    AJAX_SPINNER_ATTRS = [:spinner_next_to, :spinner_options, :spinner_at, :no_spinner, :message]

    AJAX_PUSHSTATE_ATTRS = [:push_state, :new_title]

    AJAX_ATTRS = AJAX_CALLBACKS + AJAX_UPDATE_ATTRS + AJAX_EFFECT_ATTRS + AJAX_SPINNER_ATTRS + AJAX_PUSHSTATE_ATTRS
    [:params, :errors_ok,
     :reset_form, :refocus_form ]

    def app_name(add_subsite=true)
      an = Rails.application.config.hobo.app_name
      if add_subsite && subsite
        subsite_name = t 'hobo.admin.subsite_name', :default => subsite.titleize
        an = an + " - #{subsite_name}"
      end
      an
    end

    def comma_split(x)
      case x
      when nil
        []
      when String
        x.strip.split(/\s*,\s*/)
      else
        x.compact.map{|e| comma_split(e)}.flatten
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

    # returns the number of items in the collection.  See LH #889
    def collection_count
      this.try.to_int || this.try.total_entries || (this.try.loaded? && this.try.length) || this.try.count || this.try.length
    end

    def through_collection_names(object=this)
      object.class.reflections.values.select do |refl|
        refl.macro == :has_many && refl.options[:through]
      end.map {|x| x.options[:through]}
    end


    def non_through_collections(object=this)
      names = object.class.reflections.values.select do |refl|
        refl.macro == :has_many
      end.*.name

      names - through_collection_names
    end

    def standard_fields(model, include_timestamps=false)
      fields = model.attr_order.*.to_s & model.content_columns.*.name
      fields -= %w{created_at updated_at created_on updated_on deleted_at} unless include_timestamps
      fields.reject! { |f| model.never_show? f }
      fields
    end

    def current_time
      Time.zone ? Time.zone.now : Time.now
    end

    # provides the meat for hidden-fields for-query-string and anybody
    # else who wants a list of relevant parameters.   options: :skip, :only
    def query_parameters_filtered(options = {})
      query_params = (request.query_parameters | request.request_parameters)
      if options[:only]
        query_params = query_params & options[:only]
      else
        query_params = query_params - [:render, :render_options, :"_", :page_path, :authenticity_token]
        if form_field_path
          query_params = query_params - [form_field_path[0]]
        end
      end
      query_params = query_params - options[:skip] if options[:skip]
      query_params
    end

    # this function provides the meat for the form and formlet tags.  It
    # returns a tuple of:
    #   body: html body
    #   html_attrs:  class, id, etc.
    #   ajax_attrs:  update, spinner-next-to, etc
    #   form_attrs:  action, method, enctype
    def form_helper(attributes, parameters)
      attrs, other_attrs = attributes.partition_hash([:hidden_fields, :action, :method, :web_method, :lifecycle, :owner, :multipart])
      ajax_attrs, html_attrs = other_attrs.partition_hash(HoboRapidHelper::AJAX_ATTRS)
      form_attrs = {}

      if html_attrs[:confirm]
        if ajax_attrs.blank?
          html_attrs["data-confirm"] = html_attrs.delete(:confirm) # rely on rails_ujs
        else
          ajax_attrs[:confirm] = html_attrs.delete(:confirm)
        end
      end

      form_attrs[:enctype] = html_attrs[:enctype] if html_attrs[:enctype]
      form_attrs[:enctype] ||= "multipart/form-data" if attrs[:multipart]

      new_record = self.this.try.new_record?

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
        if method == "put" || method == "delete"
          # browsers don't support put -- use post and add the Rails _method hack
          http_method_hidden = hidden_field_tag("_method", method.upcase)
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
          page_path = if (request.post? || request.put? || request.delete?) && params[:page_path]
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
        end

        Dryml.last_if = true
        [body, html_attrs, deunderscore_attributes(ajax_attrs), form_attrs]
      end
    end

    # the meat of with-fields, with-field-names, with-fields-grouped.
    # returns the list of field names
    def with_fields_helper(attrs)
      attrs[:fields].nil? || attrs[:associations].nil? or raise ArgumentError, "with-fields -- specify either fields or associations but not both"

      field_names = if attrs[:associations] == "has_many"
                      this.class.reflections.values.select { |refl| refl.macro == :has_many }.map { |refl| refl.name.to_s }

                    elsif attrs[:fields].nil? || attrs[:fields] == "*" || attrs[:fields].is_a?(Class)
                      klass = attrs[:fields].is_a?(Class) ? attrs[:fields] : this.class
                      columns = standard_fields(klass, attrs[:include_timestamps])

                      if attrs[:skip_associations] == "has_many"
                        assocs = this.class.reflections.values.reject {|r| r.macro == :has_many }.map &its.name.to_s
                        columns + assocs
                      elsif attrs[:skip_associations]
                        columns
                      else
                        assocs = klass.reflections.values.map &its.name.to_s
                        columns + assocs
                      end
                    else
                      comma_split(attrs[:fields].gsub('-', '_'))
                    end
      field_names -= comma_split(attrs[:skip]) if attrs[:skip]
      field_names
    end
end

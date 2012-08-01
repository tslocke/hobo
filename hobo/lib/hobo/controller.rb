module Hobo

  module Controller

    include AuthenticationSupport
    include Cache

    class << self

      def included(base)
        if base.is_a?(Class)
          included_in_class(base)
        end
      end

      def included_in_class(klass)
        klass.extend(ClassMethods)
        klass.class_eval do
          before_filter :login_from_cookie
          alias_method_chain :redirect_to, :object_url
          private
          def set_mailer_default_url_options
            unless Rails.application.config.action_mailer.default_url_options
              Rails.application.config.action_mailer.default_url_options = { :host => request.host }
              Rails.application.config.action_mailer.default_url_options[:port] = request.port unless request.port == 80
            end
          end
          before_filter :set_mailer_default_url_options
          @included_taglibs = []
          rescue_from ActionController::RoutingError, :with => :not_found unless Rails.env.development?
        end
        HoboRouteHelper.add_to_controller(klass)
        HoboTranslationsHelper.add_to_controller(klass)
        HoboTranslationsNormalizerHelper.add_to_controller(klass)
        HoboPermissionsHelper.add_to_controller(klass)
      end

    end

    module ClassMethods

      attr_reader :included_taglibs

      def include_taglib(src, options={})
        @included_taglibs << options.merge(:src => src)
      end

    end


    protected

    def redirect_to_with_object_url(destination, *args)
      if destination.is_one_of?(String, Hash, Symbol)
        redirect_to_without_object_url(destination, *args)
      else
        redirect_to_without_object_url(object_url(destination, *args))
      end
    end


    def hobo_ajax_response(options={})
      r = params[:render]
      if r
        ajax_update_response(r.values, options[:results] || {}, options || params[:render_options])
        true
      else
        false
      end
    end


    def ajax_update_response(render_specs, results={}, options={})
      controller, action = controller_action_from_page_path
      identifier = view_context.view_paths.find( action,
                                                 controller,
                                                 false,
                                                 view_context.lookup_context.instance_variable_get('@details')).identifier
      renderer = Dryml.page_renderer(view_context, identifier, [], controller)
      options = options.with_indifferent_access

      headers["Content-Type"] = options['content_type'] if options['content_type']

      page = options[:preamble] || "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;\n"
      for spec in render_specs
        function = spec[:function] || "hjq.ajax.update"
        dom_id = spec[:id]

        if spec[:part_context]
          part_content = renderer.refresh_part(spec[:part_context], session, dom_id)
          page << "#{function}(#{dom_id.to_json}, #{part_content.to_json})\n"
        elsif spec[:result]
          result = results[spec[:result].to_sym]
          page << "#{function}(#{dom_id.to_json}, #{result.to_json})\n"
        else
          page << "alert('ajax_update_response: render_spec did not provide action');\n"
        end
      end
      if renderer
        if options[:contexts_function]
          storage = renderer.part_contexts_storage_uncoded
          page << "#{options[:contexts_function]}(#{storage.to_json});\n"
        end
      end
      page << options[:postamble] if options[:postamble]
      render :js => page
    end

    # use this function to send arbitrary bits of javascript
    def ajax_response(response, options)
      page = options[:preamble] || "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;\n"
      page << response
      page << options[:postamble] if options[:postamble]
      render :js => page
    end


    # dryml does not use layouts
    def action_has_layout?
      false
    end


    def dryml_context
      @this
    end


    def render_tags(objects, tag, options={})
      for_type = options.delete(:for_type)
      base_tag = tag

      results = objects.map do |o|
        tag = tag_renderer.find_polymorphic_tag(base_tag, o.class) if for_type
        tag_renderer.send(tag, options.merge(:with => o))
      end.join

      render :text => results + tag_renderer.part_contexts_storage
    end


    def tag_renderer
      @tag_renderer ||= Dryml.empty_page_renderer(view_context)
    end


    def call_tag(name, options={})
      tag_renderer.send(name, options)
    end

    def site_search(query)
      results_hash = Hobo.find_by_search(query)
      all_results = results_hash.values.flatten.select { |r| r.viewable_by?(current_user) }
      if params["search_version"]
        @search_results = all_results
        hobo_ajax_response
      elsif all_results.empty?
        render :text => "<p>"+ t("hobo.live_search.no_results", :default=>["Your search returned no matches."]) + "</p>"
      else
        # TODO: call one tag that renders all the search results with headings for each model
        render_tags(all_results, :search_card, :for_type => true)
      end
    end


    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.guest?) ? nil : new_user.typed_id
      @current_user = new_user
    end


    def request_no_cache?
      request.env['HTTP_CACHE_CONTROL'] =~ /max-age=\s*0/
    end

    def not_found(error)
      if self.class.superclass.method_defined?("not_found_response")
        super
      elsif render :not_found, :status => 404
        # cool
      else
        render(:text => t("hobo.messages.not_found", :default=>["The page you requested cannot be found."]) , :status => 404)
      end
    end

  end
end



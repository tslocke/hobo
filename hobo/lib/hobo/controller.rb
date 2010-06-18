module Hobo

  module Controller

    include AuthenticationSupport

    class << self

      def included(base)
        if base.is_a?(Class)
          included_in_class(base)
        end
      end

      def included_in_class(klass)
        klass.extend(ClassMethods)
        klass.send(:include, Hobo::Translations)
        klass.class_eval do
          before_filter :login_from_cookie 
          alias_method_chain :redirect_to, :object_url
          around_filter do |controller, action|
            Thread.current['Hobo.current_controller'] = controller
            action.call
            Thread.current['Hobo.current_controller'] = nil  # should avoid memory-leakage
          end
          @included_taglibs = []
          rescue_from ActionController::RoutingError, :with => :not_found
        end
        Hobo::HoboHelper.add_to_controller(klass)
      end

      def controller_and_view_for(page_path)
        page_path.match(/(.*)\/([^\/]+)/)[1..2]
      end

      def request_host
        Thread.current['Hobo.current_controller'].request.host_with_port
      end

      def app_name
        Thread.current['Hobo.current_controller'].send(:call_tag, :app_name)
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
        redirect_to_without_object_url(destination)
      else
        redirect_to_without_object_url(object_url(destination, *args))
      end
    end


    def hobo_ajax_response(*args)
      results = args.extract_options!
      page_path = params[:page_path]
      r = params[:render]
      if r
        ajax_update_response(page_path, r.values, results)
        true
      else
        false
      end
    end


    def ajax_update_response(page_path, render_specs, results={})
      @template.send(:_evaluate_assigns_and_ivars)
      renderer = Dryml.page_renderer(@template, [], page_path) if page_path

      render :update do |page|
        page << "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;"
        for spec in render_specs
          function = spec[:function] || "_update"
          dom_id = spec[:id]

          if spec[:part_context]
            part_content = renderer.refresh_part(spec[:part_context], session, dom_id)
            page.call(function, dom_id, part_content)
          elsif spec[:result]
            result = results[spec[:result].to_sym]
            page.call(function, dom_id, result)
          else
            # spec didn't specify any action :-/
          end
        end
        page << renderer.part_contexts_storage if renderer
      end
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
      @tag_renderer ||= begin
        @template.send(:_evaluate_assigns_and_ivars)
        Dryml.empty_page_renderer(@template)
      end
    end    
    
    
    def call_tag(name, options={})
      tag_renderer.send(name, options)
    end
    
    def site_search(query)
      results_hash = Hobo.find_by_search(query)
      all_results = results_hash.values.flatten.select { |r| r.viewable_by?(current_user) }
      if all_results.empty?
        render :text => "<p>"+ ht(:"hobo.live_search.no_results", :default=>["Your search returned no matches."]) + "</p>"
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
      if self.class.superclass.method_defined?(:not_found)
        self.class.superclass.instance_method(:not_found).bind(self).call(error)
      elsif render_tag("not-found-page", {}, :status => 404)
        # cool
      else
        render(:text => ht(:"hobo.messages.not_found", :default=>["The page you requested cannot be found."]) , :status => 404)
      end
    end

  end
end


class ActionController::Base

  def home_page
    base_url
  end

end

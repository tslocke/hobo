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
        klass.class_eval do
          alias_method_chain :redirect_to, :object_url
          @included_taglibs = []
        end
        Hobo::HoboHelper.add_to_controller(klass)
      end
      
      attr_accessor :request_host

      def controller_and_view_for(page_path)
        page_path.match(/(.*)\/([^\/]+)/)[1..2]
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
      if destination.is_a?(String, Hash, Symbol)
        redirect_to_without_object_url(destination)
      else
        redirect_to_without_object_url(object_url(destination, *args))
      end
    end

    
    def hobo_ajax_response(*args)
      results = args.extract_options!
      this = args.first || @this
      page_path = params[:page_path]
      r = params[:render]
      if r
        ajax_update_response(this, page_path, r.values, results)
        true
      else
        false
      end
    end


    def ajax_update_response(this, page_path, render_specs, results={})
      add_variables_to_assigns
      renderer = Hobo::Dryml.page_renderer(@template, [], page_path) if page_path

      render :update do |page|
        page << "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;"
        for spec in render_specs
          function = spec[:function] || "_update"
          dom_id = spec[:id]
          
          if spec[:part_context]
            part_name, part_this, locals = Dryml::PartContext.unmarshal(spec[:part_context], this, session)
            part_content = renderer.call_part(dom_id, part_name, part_this, *locals)
            page.call(function, dom_id, part_content)
          elsif spec[:result]
            result = results[spec[:result].to_sym]
            page.call(function, spec[:id], result)
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
      add_variables_to_assigns
      dryml_renderer = Hobo::Dryml.empty_page_renderer(@template)
      
      results = objects.map do |o| 
        tag = dryml_renderer.find_polymorphic_tag(tag, o.class) if for_type
        dryml_renderer.send(tag, options.merge(:with => o))
      end.join
      
      render :text => results + dryml_renderer.part_contexts_storage
    end


    def site_search(query)
      results = Hobo.find_by_search(query).select{|r| Hobo.can_view?(current_user, r, nil)}
      if results.empty?
        render :text => "<p>Your search returned no matches.</p>"
      else
        # TODO: call one tag that renders all the search results with headings for each model
        render_tags(results.map {|r|r.last}.flatten, :search_card, :for_type => true)
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
    
    def not_found
      
    end

  end
end


class ActionController::Base
  
  def home_page
    ""
  end
  
end

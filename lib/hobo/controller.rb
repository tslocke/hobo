module Hobo

  module Controller

    include AuthenticationSupport
    
    def self.included(base)
      if base.is_a?(Class)
        included_in_class(base)
      end
    end
    
    def self.included_in_class(klass)
      klass.extend(ClassMethods)
      klass.class_eval do
        alias_method_chain :redirect_to, :object_url
        @included_taglibs = []
      end
      Hobo::HoboHelper.add_to_controller(klass)
    end

    module ClassMethods

      attr_reader :included_taglibs

      def include_taglib(src, options={})
        @included_taglibs << if options[:from_plugin]
                               'plugins/' + options[:from_plugin] + '/taglibs/' + src
                             else
                               src
                             end
      end
    end

    protected
    
    def redirect_to_with_object_url(destination, view=nil)
      if destination.is_a?(String, Hash, Symbol)
        redirect_to_without_object_url(destination)
      else
        redirect_to_without_object_url(object_url(destination, view))
      end
    end

    def hobo_ajax_response(this=nil, results={})
      this ||= @this
      part_page = params[:part_page]
      r = params[:render]
      if r
        ajax_update_response(this, part_page, r.values, results)
        true
      else
        false
      end
    end


    def ajax_update_response(this, part_page, render_specs, results={})
      before_ajax if respond_to? :before_ajax
      add_variables_to_assigns
      renderer = Hobo::Dryml.page_renderer(@template, [], part_page) if part_page

      render :update do |page|
        page << "var _update = typeof Hobo == 'undefined' ? Element.update : Hobo.updateElement;"
        for spec in render_specs
          function = spec[:function] || "_update"

          if spec[:as] or spec[:part]
            obj = if spec[:object] == "this" or spec[:object].blank?
                    this
                  elsif spec[:object] == "nil"
                    nil
                  else
                    Hobo.object_from_dom_id(spec[:object])
                  end

            if spec[:as]
              part_content = render(:partial => (Hobo::ModelController.find_partial(obj.class, spec[:as])),
                                 :locals => { :this => obj })
              page.call(function, spec[:id], part_content)
              
            elsif spec[:part]
              dom_id = spec[:id] || spec[:part]
              part_content = renderer.call_part(dom_id, spec[:part], obj)
              page.call(function, dom_id, part_content)
            end
            
          elsif spec[:result]
            result = results[spec[:result].to_sym]
            page.call(function, spec[:id], result)
            
          else
            # spec didn't specify any action :-/
          end
        end
        if renderer
          renderer.part_contexts.each_pair do |dom_id, p|
            part_id, model_id = p
            page.assign "hoboParts.#{dom_id}", [part_id, model_id]
            
            # not sure why this isn't happending automatically
            # but it's messing up ARTS, so chuck a newline in
            page << "\n"
          end
        end
      end
    end


    def render_tag(tag, options={}, render_options={})
      add_variables_to_assigns
      render({:text => Hobo::Dryml.render_tag(@template, tag, options),
               :layout => false }.merge(render_options))
    end


    def render_tags(objects, tag, options={})
      add_variables_to_assigns
      dryml_renderer = Hobo::Dryml.empty_page_renderer(@template)
      render :text => objects.map {|o| dryml_renderer.send(tag, options.merge(:obj => o))}.join +
                      dryml_renderer.part_contexts_js
    end


    def site_search(query)
      results = Hobo.find_by_search(query).select {|r| Hobo.can_view?(current_user, r, nil)}
      if results.empty?
        render :text => "<p>Your search returned no matches.</p>"
      else
        render_tags(results, :name => "card", :for_type => true)
      end
    end


    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end


    def request_no_cache?
      request.env['HTTP_CACHE_CONTROL'] =~ /max-age=\s*0/
    end
    
    def not_found
      
    end

  end
end

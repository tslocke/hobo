# Save Context for table and table-plus

Originally written by dziesig on 2011-01-24.

One of my clients has tables with thousands of rows which are related positionally (adjacency is relevant) and have searchable values.  Once a row is found it is often used in many subsequent operations. Consequently using the page navigator for rows in the middle of the current sort order is cumbersome.

It was requested that I save the context between visits to the index pages to avoid the "page chase" that occurred when the user needed to return to the most recent row (or adjacent rows).

Inspired by Dean's saving of filter_parameters in the session, but needing a more general solution, I put together a pair of subprograms to save and restore the context from within the controllers of the various tables.

New file lib/table_plus_support.rb

    module TablePlusSupport
      
      def self.save_page(params, per_page, session, ignore=nil)
        field_list = ''
    # If we have a field to ignore (usually one with much data),
    # get a list of all columns excluding that one.
    # TODO Generalize this to allow ignore to be both a string and an array
        if !ignore.nil?
          index_fields = column_names.select{ |col| col != ignore }
          for i in index_fields do
            field_list = field_list + i + ', '
          end
          field_list = field_list[0..-3]
        end
    # Default to the first page.
        page = 1
    # Generate a session key from the name of the table.
        controller = params[:controller]
        key = controller+'-page'
    
        if params[:page]
    # If we have a page parameter, save it in the session
          page = params[:page].to_i      
          session[key] = page
        else
    # If we don't have a page parameter get the page from the session if it exists
          page = session[key] if session[key]
        end
    # Return a series of tAssoc to satisfy hobo_index, here I presume that
    # pagination is desired since this wouldn't be called without it.
        return :per_page => per_page, :page => page, :paginate=> true if ignore.nil?
        return :per_page => per_page, :page => page, :paginate=> true, :select => field_list
      end
  
      def self.save_param(params,param,session)
        controller = params[:controller]
        key = controller + '-' + param.to_s
        sort = nil
        if params[param]
    # If we have a value in params[param], save it in the session
          value = params[param]
          session[key] = value
        else
    # The following line is weird.  I tried using session[key].class == 'String',
    # but it always evaluated FALSE no matter what version of 'String', "String", :String
    # I used, even though session[key].class and session[key].class.inspect both printed "String"
    # Weirder still, session[key].class == session[key].class.inspect also evaluated FALSE
    # This version works, so ...

    # If we don't have a value in params[param], but we do have a string in session[key]
    # then use the value in the key
          value = session[key] if session[key].class.inspect == 'String'
        end
    # set params[param] if we have a value for sort.
        params[param] = value if value    
      end
    end

This does not mess up the controller too badly.  An example, based on a smaller table which saves U.S. States and Canadian Provinces is:

    require "table_plus_support"
    
    class StateProvsController < ApplicationController
    
      hobo_model_controller
    
      auto_actions :all
      
      def index
        TablePlusSupport::save_param(params,:sort,session)
        TablePlusSupport::save_param(params,:search,session)
        hobo_index StateProv.apply_scopes(:search => [params[:search],:full_name,:name],:order_by => parse_sort_param(:name, :full_name)), TablePlusSupport::save_page(params,10,session)
      end

    end

One somewhat obvious note:  The search parameter will be saved until it is reset by issuing "Go" with a blank search box.  Fortunately, the search box is re-populated so it is obvious that the filter is still in place.



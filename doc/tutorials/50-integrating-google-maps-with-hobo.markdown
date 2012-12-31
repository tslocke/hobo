# Integrating Google Maps with Hobo

Originally written by Dean on 2010-05-25.

This recipe answers [contact form and google maps maybe](/questions/42-contact-form-and-google-maps-maybe)

Integrating Google Maps into a Hobo application is very simple.  The [YM4R](http://ym4r.rubyforge.org/) plugin does all of the heavy lifting of generating the necessary Javascript.

#### Install YM4R/GM

    ruby script/plugin install svn://rubyforge.org/var/svn/ym4r/Plugins/GM/trunk/ym4r_gm

#### Set up a Google Map Tag
In application.dryml, define the following tags:

    <def tag="google-map" attrs="id, ne-lat, ne-long, sw-lat, sw-long, width, height">
      <%  @map = GMap.new(id)
          @map.control_init(:large_map => true,:map_type => true)
          @map.center_zoom_on_points_init([ne_lat,ne_long],[sw_lat,sw_long]) %>
      <do param='default'/>
      <%=  @map.div(:width => width, :height => height) %>
      <%=  @map.to_html %>
    </def>

    <def tag="marker" attrs="lat, long, title, info">
      <%  @map.overlay_init(GMarker.new([lat,long],:title => title, :info_window => info)) %>
    </def>

The attributes for google-map are:
* id - the id assigned to the div element containing the map.  Different maps on the same page should have a different id.
* ne-lat, ne-long, sw-lat, sw-long - the map will be automatically scaled to contain a bounding box defined by these two points
* width, height - the size of the map to display. Any HTML units of measurement are accepted.

The maker tag places markers on the map.  Its attributes are:
* lat, long - the location of the marker
* title - displayed as a tooltip when you mouseover the marker
* info - HTML code displayed in a popup when you click on the marker

#### Insert a Map in a Page
Each page containing a map first needs the Google Maps Javascript library included:

    <append-scripts:>
      <%= GMap.header %>
    </append-scripts:>

Then to create the map:

      <google-map id="sites" ne-lat="35.0" ne-long="36.0" sw-lat="147.0" sw-long="149.0"
                  width="100%" height="500">
            <marker lat="35.5" long="148.0" title="Marker 1" info="This is <b>Marker 1</b>"/>
            <marker lat="35.25" long="148.0" title="Marker 2" info="This is <b>Marker 2</b>"/>
            <marker lat="35.5" long="148.5" title="Marker 3" info="This is <b>Marker 3</b>"/>
      </google-map>

#### A More Complex Example
I have number of sites as defined by the model:

    class Site < ActiveRecord::Base

      hobo_model # Don't put anything above this
 
      fields do
        code        :string, :required, :unique, :name => true
        site_name   :string, :required
        latitude    :decimal, :precision => 15, :scale => 10
        longitude   :decimal, :precision => 15, :scale => 10
        timestamps
      end
 
      belongs_to :district
    end

where each site has a code, site name and belongs to a geographical district.

The index.dryml page to display these sites on a map is:

    <index-page>
      <append-scripts:>
        <%= GMap.header %>
      </append-scripts:>
      <top_page_nav: replace/>

      <collection: replace>
        <if>
          <% minmax_lat =  this.*.latitude.reject{|x| x.nil?}.minmax
          minmax_long = this.*.longitude.reject{|x| x.nil?}.minmax  %>
          <google-map name="sites"
                      ne-lat="&minmax_lat[1] + 0.0005" ne-long="&minmax_long[1] + 0.0005"
                      sw-lat="&minmax_lat[0] - 0.0005" sw-long="&minmax_long[0] - 0.0005"
                      width="100%" height="500">
            <repeat>
              <marker if="&this.latitude and this.longitude" lat="&this.latitude"
                      long="&this.longitude" title="&this.code"
                      info="&'<a href=' + object_url(this) + '><b>' + this.code 
                             + '</b></a>' + '<br/>' + this.site_name"/>
            </repeat>
          </google-map>
        </if>

        <table-plus: fields="this, site_name, district">
          <prepend-header:>
            <div class="filter">
              District: <filter-menu param-name="district" options="&District.all"/>
            </div>
          </prepend-header:>
          <empty-message:>No sites match your criteria</empty-message:>
        </table-plus:>
      </collection:>
      <bottom_page_nav: replace/>
    </index-page>


The index page will display all of the site locations on a map and scale the map to right size to contain them all.  Note - some of my sites don't have location data so I filter them out from the map.

The user is able to filter the list of sites using the table-plus filter and the map will only display those sites.  The corresponding controller is:

    class SitesController < ApplicationController

      hobo_model_controller

      auto_actions :all

      def index
    
        scopes = {:search => [params[:search], :site_name],
          :district_is => params[:district],
          :order_by  => parse_sort_param(:code, :district, :site_name)}

        hobo_index Site.apply_scopes(scopes), :include => [:district],
          :paginate => false

      end

   end

One downside is that the map will only show those sites that are displayed on that page, so if you have more than one page of results you will need to turn off the paginator with :paginate => false.

YM4R has a number of other features including geocoding and getting maps from other providers such as Yahoo and Microsoft.

#### Google API Key
Google allows you to embed a map in your application freely if it is accessed locally at http://localhost.

If your application is available remotely, Google requires you to register at [http://code.google.com/intl/en/apis/maps/signup.html](http://code.google.com/intl/en/apis/maps/signup.html) and obtain an API key for your site.

Your API key for each address needs to be recorded in config/gmaps_api_key.yml


# Using multiple `<sortable-collection>`'s for the same model on the same page

Originally written by Henry Baragar on 2010-04-09.

Suppose you have a list (of requests for example) that are partitioned into a number of sublists that you want to be able to reorder individually on some page.  

Using the requests, example, the Request model might look like this:

    class Request < ActiveRecord::Base
 
      hobo_model # Don't put anything above this
 
      belongs_to :project
      acts_as_list :scope => %q(project_id = #{project_id} and priority = '#{priority}')
 
      fields do
        title       :string, :required
        priority    enum_string(:high, :medium, :low), :required, :default => 'medium'
        timestamps
      end
 
      validates_uniqueness_of :title, :scope => :project_id

    end

Since we said that requests belong to projects, we better add some has_many's to the Project model:

      has_many :requests, :dependent => :destroy
      has_many :high_priority_requests, :class_name => 'Request',
        :conditions => {:priority => 'high'}
      has_many :medium_priority_requests, :class_name => 'Request',
        :conditions => {:priority => 'medium'}
      has_many :low_priority_requests, :class_name => 'Request',
        :conditions => {:priority => 'low'}

And, to get the requests automatically displayed on the project page, we need the following in the projects viewhints file:

      children :requests

Now, we are ready to replace the whole list of requests with three sublists: one each for the low, medium and high priority requests.  We create a show page for projects that looks like:

    <show-page>
      <collection-section: replace>
        <h3>High Priority Requests</h3>
        <sortable-collection:high_priority_requests id="high_priority_request_ordering"/>
        <h3>Medium Priority Requests</h3>
        <sortable-collection:medium_priority_requests id="medium_priority_request_ordering"/>
        <h3>Low Priority Requests</h3>
        <sortable-collection:low_priority_requests id="low_priority_request_ordering"/>
      </collection-section:>
    </def>

Note that we had to create a different div id for each of the sublists, because these id's are required to be unique on the page.

However, hobo uses the div id as the parameter to specify how the elements were reordered.  Thus, we add the following method to the Requests controller:

      def reorder
        # We need to (un)distinguish the high, medium & low priority request sections
        request_ordering = params.keys.grep(/request_ordering$/)[0]
        params['request_ordering'] = params[request_ordering]
        hobo_reorder
      end

Now, the application can the multiple &lt;sortable-collection&gt;'s for the same model on the same page.


# A Simple Way to Do Location-Based Breadcrumbs

Originally written by hobokoop on 2011-03-20.

For ease of navigation, our team decided to incorporate breadcrumbs into our Hobo site. 

In this method below, the breadcrumbs are based not on history, but on the current location of the user, the url. Since historical navigation can easily get quite deep and complex, it seems the wiser choice to maintain our adherence to the KISS (keep-it-simple-stupid) principle. If you're curious as to a discussion of the pros/cons of historical versus hierarchical breadcrumbs, i rather enjoyed this: http://derivadow.com/2010/02/18/the-problem-with-breadcrumb-trails/.

Basically, I placed the following get\_bread\_crumb() function in my application's FrontHelper: 

	def get_bread_crumb(url, root_model=nil, separator = " &raquo; ")
		root_model = root_model.pluralize
		breadcrumb = []
		so_far = []
		elements = url.split('/')
		last_element = elements.last

		# remove the last element, let dryml specify <name/>
		if last_element == 'edit'
			elements.pop(2)
		else
			elements.pop
		end

		elements.each_with_index do |element, index|
			so_far << element
			url = so_far.join('/')

			breadcrumb << if element =~ /^[0-9]*$/
				link_to_if(element != last_element, elements[i-1].constantize.find(element).name.humanize, url) rescue element
			else
				link_to_if(element != last_element, element.titleize, url)
			end
		end

		# prepend the root_model IF we're not already in it!
		if root_model != elements[1]
			breadcrumb.insert(1,link_to(root_model.titleize, '/' + root_model))
		end

		# return the breadcrumb
		breadcrumb.join(separator) + separator
	rescue
		'Not available'
	end

Then, simply place in application.dryml:

	<!-- ====== Breadcrumb Navigation ====== -->
	
	<extend tag="new-page">
	  <old-new-page merge> 
	    <content-header:>
	      <%= get_bread_crumb(request.path, 'eteachable').html_safe%> New<br/>
	    </content-header:>
	  </old-new-page>
	</extend>
	 
	<extend tag="show-page">
	  <old-show-page merge> 
	    <content-header:>
	      <%= get_bread_crumb(request.path, 'eteachable').html_safe %><name/><br/>
	    </content-header:> 
	  </old-show-page>
	</extend> 
	
	<extend tag="index-page">
	  <old-index-page merge> 
	    <content-header:>
	      <%= get_bread_crumb(request.path, 'eteachable').html_safe %><name/><br/>
	    </content-header:>
	  </old-index-page>
	</extend> 
	
	<extend tag="edit-page">
	  <old-edit-page merge> 
	    <content-header:>
	      <%= get_bread_crumb(request.path, 'eteachable').html_safe %><name/><br/>
	      <delete-button update="self"/>
	    </content-header:>
	  </old-edit-page>
	</extend> 

I chose NOT to include the name of the current page in the function for flexibility, leveraging Hobo's nice rendering of the name based on the context. For instance, on our Eteachables index page, we have the following DRYML:

      <%= get_bread_crumb(request.path, 'eteachable').html_safe %><name/><br/>

which nicely generates the count of Eteachables in the breadcrumb: 

	» Eteachables » 3 Eteachables 

We also chose to have a root model, in this case Eteachables, so the user can always quickly return to this primary location. For instance, one might navigate to the Math learning category, and while the url simply states 

	/learning_categories/1-math 

the breadcrumb shows Eteachable as the root:

	» Eteachables » Learning Categories » Math

In sum, the breadcrumbs, being just below the tabs, are a quick way to navigate while keeping it all very Hobo-feeling!

Now if anyone can help me get the Edit button back on the Show page, I think that's the primary deficiency I've noticed at this juncture. I'll update the recipe with that edit once resolved. In the meantime, enjoy!

*Special thanks for the considerable head start via https://gist.github.com/446655.*



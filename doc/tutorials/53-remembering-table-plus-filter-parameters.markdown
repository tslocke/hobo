# Remembering <table-plus> Filter Parameters

Originally written by Dean on 2010-07-08.

When you are using a `<table-plus>` on an index page, it is often nice to be able to remember the filter parameters that the user had set.  This allows the user to wander off to other pages and have their filter parameters restored when they subsequently return to the index page.

For example, in a work tasking application, users use filters to select the subset of tasks from the task list that they wish to work on.  Working on each task takes the user away from the index screen.  When they have completed the task and return to the index screen, their filter parameters would normally have been reset and they now need to reselect their subset of tasks they are working on. It is much more user friendly to have the filter parameters to remain in use in the current session until they explicitly change them.

There are two parts to the solution.

First, you need to save the filter parameters.  In the `index` action in the controller, add the lines:

     filter_parameters = request.parameters 
     filter_parameters.delete(:controller) 
     filter_parameters.delete(:action) 
     session[:filter_parameters] = filter_parameters 
 
This gets the parameters from the request, strips out the action and controller, and then stores them in the session hash. When ever the filter parameters are changed, they are stored in the session.  This also works with pagination, so the user will return to the page of results they were last on - just strip out the `page` parameter if you don't want this.

Secondly, we need to restore them when the user returns to the index page.  We do this using the assumption that there is only one path to the index page, namely through the navigation bar.  The filter parameters are restored by appending them to the url of the index page with:

    <nav-item with="&Survey" params="&session[:filter_parameters]"> 
        <ht key="surveys.nav_item">Surveys</ht> 
     </nav-item> 

The `params` attribute of the `<nav-item>` tag converts the hash to a http parameter string and attaches it to the end of the url. 

Now when the user clicks on the nav item in the nav bar, they will return to the index page just how they had left it.


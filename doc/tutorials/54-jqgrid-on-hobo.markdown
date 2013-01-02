# jqGrid on Hobo

Originally written by allen13 on 2010-07-19.

About a year ago I started working with hobo and really liked what I saw. I could do some amazing things really fast. The only piece that felt like it was missing something was the table-plus tag. So I started working on an alternative and decided to start from the well known jqGrid widget. I went on to install every rails jqGrid plugin in existance and found that none of them were quite what I wanted.

The main features of my incarnation of the jqGrid plugin are:
 - Uses a rails model directly instead of the limiting auto-detect method
 - Uses a randomly generated id name so you can put as many grids of the same or different types as you want on the same page
 - Direct editing of the jqGrid properties through hash properties e.g. :title => "Title"
 - Easy to edit default jqGrid properties (plan to take it a step further and implement them as yaml later)
 - Uses the # symbol as the first character to identify a function property (I implemented the ondblclickrow property this way)
 - Double clicking on rows and anything else that is possible with the jqGrid widget...

##[rails-jqgrid @ Github](http://github.com/allen13/rails-jqgrid)

This is a rails plugin dedicated to the great jqGrid javascript widget. I had two rails concepts in mind when I created 
it, "DRY it up" and "Convention over configuration". I managed to get jqGrid to work with two lines of code ( one if you 
don't count the styling). A standard set of grid options has already been defined, so all you really need to do is give 
it a model. Enjoy :-)

Usage Instructions:

    #For the jQuery grid theme
    <%= jqgrid_theme("theme-name") %>
    #For the grid
    <%= jqgrid(Model,[optional standard jqGrid options here])) %>

Example:

    <index-page>
       <content-header:>
             <%= jqgrid_theme("pepper-grinder") %>
       </content-header:>
       <content-body:>
             <%= jqgrid(Log,:fields =>"exercise_type,duration_in_mins,date") %>
       </content-body:>
    </index-page>


Copyright (c) 2010 \[name of plugin creator\], released under the MIT license


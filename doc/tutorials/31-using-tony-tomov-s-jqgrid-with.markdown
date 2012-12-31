# Using Tony Tomov's jqGrid with Hobo

Originally written by brett on 2009-07-07.

The hobo-jqi plugin supports using the jqGrid grid with Hobo.

####Some jqGrid features:####

* resizable columns
* paging controls
* crud functions
* JQuery UI theming

and many more see them at: [http://www.trirand.com/jqgrid35/jqgrid.html](http://www.trirand.com/jqgrid35/jqgrid.html)

See a [screencast install/demo](http://www.screencast.com/t/7nCgbl5L3)

To install the grid

1. go to the plugins directory: cd vendor/plugins
2. load the plugin from github: git clone git://github.com/blizz/hobo-jqi.git
3. go to the root directory of project: cd ../..
4. run the install rake task: rake hobo\_jqi:install
5. add the following line to app/views/taglibs/application.dryml<br/>
&lt;include src="hobo-jqi-all" plugin="hobo-jqi"/&gt;
6. add this line to the header of an index page:<br/>
&lt;jqi-grid-includes theme="smoothness"/&gt;
7. add this line to the content section of an index page:<br/>
&lt;jqi-grid id="jqgrid"/&gt;
8. restart your server







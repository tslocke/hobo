# Cut and paste (almost) recipe to add the tiny-mce editor to hobo apps.

Originally written by dziesig on 2011-09-07.

In my RoR days, I used the tiny-mce editor when ever I wanted to edit html fields.

I searched the web for hobo versions of html editors and found Hoboyui in another recipe in this Cookbook.  I followed the recipe and got an editor that worked, but all of the buttons were blank.  Further investigation showed that the Yui folks were rationalizing their directory structure and even some of their own members were complaining about blank buttons.  I could not find the button image data anywhere on their website or on the rest of the web for that matter.  After hours of searching, I gave up.  Remembering the success I had with tiny-mce in the past, I decided to hoboize it.

If you don't already have it:

     [sudo] gem install tiny_mce

edit your Gemfile, adding the line:

     gem 'tiny_mce'

then:

     bundle install

edit config/application.rb, adding the line:

     config.gem 'tiny_mce' 

edit taglibs/application.dryml, adding the lines:

    <extend tag="page">
        <old-page merge>
            <append-head:>
                <script src="/javascripts/hoboTinyMce.js" type="text/javascript"></script>
                <script type="text/javascript">
                    document.observe("dom:loaded", function() {tinymce_page_loaded();} );
                </script>
                <%= include_tiny_mce_if_needed %>   
            </append-head:>
        </old-page>
    </extend>

Add the file public/javascripts/hoboTinyMce.js (see comments about file name):

    // This file is hoboTinyMce.js
    //
    // I had extreme agony when the file was named "hobo_tiny_mce.js"
    // the editor would not initialize and the log showed many unresolved
    // javascript files.  After renaming the file, everything just worked.
    //
    function tinymce_page_loaded()
    {
        var elements=document.getElementsByTagName("textarea");
        for(i = 0;i < elements.length;i++)
        {
            className = elements[i].className
    // Only diddle with hobo :html fields, ignore :text, etc.    
            if(className.indexOf('html') > -1 )
            {
                elements[i].className = className + " mceEditor";
            }
        }
    }

Now modify the controllers of those pages that need the html editor.  This is where you can customize the appearance of tiny-mce on a page-by-page basis.  If you do not include a "uses_tiny_mce" line, the page will not invoke tiny-mce even if the model has an :html field.

controller 1:

    uses_tiny_mce # shows a very simple editor (with controls on the bottom as the default).

controller 2:

    uses_tiny_mce(:options => {  :theme => 'advanced', :theme_advanced_toolbar_align => "left"} ) # fancier editor

Note that the :options hash allows you to customize all of the pages associated with any particular controller.  It is the equivalent of the javascript tiny_mce:init( .... ) except that it works on a controller-by-controller basis whereas the init works on every editor on the site.  See http://tinymce.moxiecode.com/documentation.php for details about options and themes.  There are so many configuration items that it would be inappropriate to show them all here.  Besides the doc site does a much better job of explaining them than I can.






# Generating DRYML from the command line

Originally written by Bryan Larsen on 2009-03-09.

This recipe is obsolete, there's now a much easier way.   See [this hobo-users post](http://groups.google.com/group/hobousers/browse_thread/thread/9501d496add0ad52).


 
After using DRYML for a while, you may want to generate HTML for use outside of rails.  Here's how I did it.  Note that both of these files live inside a working Hobo skeleton.

lib/tasks/render\_test.rake:

    desc "render test.dryml"
    task :render_test => ["#{RAILS_ROOT}/app/views/taglibs/test.dryml", :environment] do |t|
      src = open(t.prerequisites.first).read
      locals = []
      imports = []
      renderer_class = Hobo::Dryml.make_renderer_class(src, File.dirname(t.prerequisites.first), locals, imports)
      assigns = {}
      view = ActionView::Base.new(ActionController::Base.view_paths, assigns)  
      view.extend(ActionView::Helpers::TagHelper)
      view.extend(Hobo::HoboHelper)
      view.extend(Hobo::RapidHelper)
      renderer = renderer_class.new(File.basename(t.prerequisites.first, ".dryml"), view)
      page_this = nil
      page_locals = []
      puts renderer.render_page(page_this, page_locals).strip
    end

app/views/taglibs/test.dryml:

    <include src="core" plugin="hobo/hobo"/>
    <include src="rapid" plugin="hobo/hobo"/>

    <def tag="hello">
      <p>Hello!</p>
    </def>

    <html>
      <hello />
    </html>

and then to get the html:

    rake render_test

Note: Most tags work, but the `<repeat>` tag does not yet -- the functions needed are provided by renderer_class but aren't being found.  If you can help, please comment!


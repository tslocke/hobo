#  This requires a working hobo skeleton.  Rather than create a
#  symbolic dependency, I haven't included the skeleton.
#
#  Link this file from lib/tasks/render.rake and link
#  doc_generator.dryml to app/views/taglibs in your skeleton

desc "generate all"
task :generate_all => ["../hobo-contrib-gh-pages/README.html", "../hobo-contrib-gh-pages/documentation.html"]

desc "generate README.html"
file "../hobo-contrib-gh-pages/README.html" => [:environment, "#{RAILS_ROOT}/../hobo-contrib/README.markdown"] do |t|
  sh "maruku --html #{RAILS_ROOT}/../hobo-contrib/README.markdown -o #{RAILS_ROOT}/../hobo-contrib-gh-pages/README.html"
end

desc "generate documentation"
file "../hobo-contrib-gh-pages/documentation.html" => ["#{RAILS_ROOT}/app/views/taglibs/doc_generator.dryml", :environment]+Dir["#{RAILS_ROOT}/../hobo-contrib/taglibs/**/*.dryml"] do |t|
  
  require 'maruku'

  taglibs = Dir["#{RAILS_ROOT}/../hobo-contrib/taglibs/**/*.dryml"].reject {|filename|
    File.basename(filename).match(/^hobo-contrib-.*/)
  }.map {|filename|
    Hobo::Dryml::DrymlDoc::Taglib.new("#{RAILS_ROOT}/../hobo-contrib/taglibs", filename)
  }

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
  page_locals = ""
  open(t.name, "w").write(renderer.render_page(taglibs, page_locals).strip)
end


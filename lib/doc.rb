require 'rubygems'
require 'maruku'
require 'dryml'
require 'action_view'
require 'action_controller'

taglibs = Dir["../taglibs/**/*.dryml"].reject {|filename|
  File.basename(filename).match(/^hobo-jquery-.*/)
}.map {|filename|
  Dryml::DrymlDoc::Taglib.new("../taglibs", filename)
}

out=Dryml.render(open("doc.dryml").read, {:this => taglibs}, "doc.dryml")

open("../documentation/doc.html", "w").write(out)

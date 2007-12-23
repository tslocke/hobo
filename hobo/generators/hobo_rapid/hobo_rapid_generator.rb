require 'find'

class HoboRapidGenerator < Hobo::Generator

  default_options :import_tags => false

  def manifest
    if options[:command] == :create
      import_tags if options[:import_tags]
    end
    
    record do |m|
      m.file "hobo-rapid.js", "public/javascripts/hobo-rapid.js"
      m.file "lowpro.js", "public/javascripts/lowpro.js"
      m.file "reset.css", "public/stylesheets/reset.css"
      m.file "hobo-rapid.css", "public/stylesheets/hobo-rapid.css"
      create_all(m, "themes/default/public", "public/hobothemes/default")
      create_all(m, "themes/default/views", "app/views/taglibs/themes/default")
    end
  end
  
  def import_tags
    path = File.join(RAILS_ROOT, "app/views/taglibs/application.dryml")

    tag = "<include src=\"rapid\" plugin=\"hobo\"/>\n\n<set-theme name=\"default\"/>\n"
      
    src = File.read(path)
    return if src.include?(tag)

    # first try putting it before the first tag
    done = src.sub!(/<(?!!)/, tag + "\n<")
    
    # otherwise append it
    src << tag unless done
    
    File.open(path, 'w') {|f| f.write(src) }
  end


  protected
    def banner
      "Usage: #{$0} #{spec.name} [--import-tags]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--import-tags",
             "Modify taglibs/application.dryml to import hobo-rapid and theme tags ") do |v|
        options[:import_tags] = true
      end
    end
end

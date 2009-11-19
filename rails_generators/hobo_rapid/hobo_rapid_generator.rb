require 'find'

class HoboRapidGenerator < Hobo::Generator

  default_options :import_tags => false

  def manifest
    if options[:command] == :create
      import_tags if options[:import_tags]
    end

    record do |m|
      m.file "hobo-rapid.js",      "public/javascripts/hobo-rapid.js"
      m.file "lowpro.js",          "public/javascripts/lowpro.js"
      m.file "IE7.js",             "public/javascripts/IE7.js"
      m.file "ie7-recalc.js",      "public/javascripts/ie7-recalc.js"
      m.file "blank.gif",          "public/javascripts/blank.gif"
      m.file "reset.css",          "public/stylesheets/reset.css"
      m.file "hobo-rapid.css",     "public/stylesheets/hobo-rapid.css"
      create_all(m, "themes/clean/public", "public/hobothemes/clean")
      create_all(m, "themes/clean/views", "app/views/taglibs/themes/clean")
      
      if with_admin_site?
        options = ["admin"]
        options.unshift "--make-front-site" unless File.exist?('app/views/taglibs/front_site.dryml')
        options.unshift "--invite-only" if invite_only?
        m.dependency 'hobo_admin_site', options
      end
    end
  end

  def import_tags
    path = File.join(RAILS_ROOT, "app/views/taglibs/application.dryml")

    tag = %(<include src="rapid" plugin="hobo"/>

<include src="taglibs/auto/rapid/cards"/>
<include src="taglibs/auto/rapid/pages"/>
<include src="taglibs/auto/rapid/forms"/>

<set-theme name="clean"/>
)

    if with_admin_site?
      tag += %(
<extend tag="page">
  <old-page merge>
    <footer:>
      <a href="&admin_users_url" if="&current_user.administrator?">Admin</a>
    </footer:>
  </old-page>
</extend>
) 
    end

    src = File.read(path)
    return if src.include?(tag)

    # first try putting it before the first tag
    done = src.sub!(/<(?!!)/, tag + "\n<")

    # otherwise append it
    src << tag unless done

    File.open(path, 'w') {|f| f.write(src) }
  end


  def with_admin_site?
    options[:admin]
  end
  
  def invite_only?
    options[:admin] == :invite_only
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} [--import-tags] [--admin | --invite-only]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--import-tags",
             "Modify taglibs/application.dryml to import hobo-rapid and theme tags ") do |v|
        options[:import_tags] = true
      end
      opt.on("--admin",
             "Generate an admin subsite") { |v| options[:admin] = true }
      opt.on("--invite-only",
             "Generate an admin subsite with features for an invite only app") { |v| options[:admin] = :invite_only }
    end
end

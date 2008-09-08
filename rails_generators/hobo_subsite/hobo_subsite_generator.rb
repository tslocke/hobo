require 'fileutils'

class HoboSubsiteGenerator < Rails::Generator::NamedBase
  
  default_options :rapid => true
  
  def subsite_name
    class_name
  end
  
  
  def generating?
    options[:command] == :create
  end
  
  
  def app_name
    front_name = File.read('app/views/taglibs/front_site.dryml').grep(%r(<def tag="app-name">(.*)</def>)){ $1 } rescue nil
    front_name ? "#{front_name} - #{subsite_name.titleize}" : subsite_name.titleize
  end
  
  
  def can_mv_application_to_front_site?
    File.exist?('app/views/taglibs/application.dryml') && !File.exist?('app/views/taglibs/front_site.dryml')
  end
  
  
  def manifest
    if generating? && can_mv_application_to_front_site? && options[:make_front_site].nil?
      puts "front_site.dryml is missing -- please specify either --make-front-site or --no-front-site"
      exit 1
    end
    
    record do |m|
      if generating? && options[:make_front_site]
        unless can_mv_application_to_front_site?
          puts "Cannot rename application.dryml to front_site.dryml"
          exit 1
        end
        puts "Renaming app/views/taglibs/application.dryml to app/views/taglibs/front_site.dryml"
        FileUtils.mv('app/views/taglibs/application.dryml', 'app/views/taglibs/front_site.dryml')
        m.template "application.dryml", File.join('app/views/taglibs/application.dryml')  
      end
      
      m.directory File.join('app', 'controllers', file_name)
      m.directory File.join('app', 'views', file_name)

      m.template "controller.rb", File.join('app/controllers', file_name, "#{file_name}_site_controller.rb")
      m.template "site_taglib.dryml",  File.join('app/views/taglibs', "#{file_name}_site.dryml")
    end
  end


  protected
    def banner
      "Usage: #{$0} #{spec.name} [--make-front-site | --no-front-site]"
    end


    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--make-front-site", "rename application.dryml to front_site.dryml ") do |v|
        options[:make_front_site] = true
      end
      opt.on("--no-front-site", "do not rename application.dryml to front_site.dryml ") do |v|
        options[:make_front_site] = false
      end
      opt.on("--no-rapid", "don't include Rapid features in the subsite taglib") do |v|
        options[:rapid] = false
      end
    end
end

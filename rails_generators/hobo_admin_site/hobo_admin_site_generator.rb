require 'fileutils'

class HoboAdminSiteGenerator < HoboSubsiteGenerator
  
  default_options :rapid => true
  
  def manifest
    m = super
    
    m.template "admin.css", File.join('public/stylesheets/admin.css') 
    if invite_only?
      m.dependency "hobo_model_controller", ["admin/user"]
      m.template "users_index.dryml", "app/views/admin/users/index.dryml"
    end
    m
  end
  
  def invite_only?
    options[:invite_only]
  end

  protected

    def banner
      "Usage: #{$0} #{spec.name} [--make-front-site | --no-front-site] [--invite-only]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--make-front-site", "rename application.dryml to front_site.dryml") do |v|
        options[:make_front_site] = true
      end
      opt.on("--no-front-site", "do not rename application.dryml to front_site.dryml ") do |v|
        options[:make_front_site] = false
      end
      opt.on("--no-rapid", "don't include Rapid features in the subsite taglib") do |v|
        options[:rapid] = false
      end
      opt.on("--invite-only", "Add features for an invite only website") do |v|
        options[:invite_only] = true
      end
    end

end

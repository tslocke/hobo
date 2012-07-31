module Generators
  module Hobo
    Plugin = classy_module do

      protected
      def gem_with_comments(*args)
        options = args.extract_options!
        name = args[0]

        unless File.read("Gemfile") =~ /^gem ("|')#{name}/
          if (comments = options.delete(:comments))
            append_file "Gemfile", "#{comments}\n", :verbose => false
          end

          gem(args[0], args[1], options)
          true
        else
          false
        end
      end

      def install_plugin_helper(name, git_path, options)
        plugin = name.dup
        unless options[:skip_gem]
          gem_options = {}
          if git_path
            if git_path =~ /:/
              gem_options[:git] = git_path
            else
              gem_options[:path] = git_path
            end
          end
          gem_options[:comments] = "# #{options[:comments]}" if options[:comments]
          need_update = gem_with_comments(plugin, options[:version], gem_options)
        end

        if options[:subsite].nil? || options[:subsite] == "all"
          subsites = ['front'] + ::Hobo.subsites
        else
          subsites = [options[:subsite]]
        end

        subsites.each do |subsite|
          inject_js_require(name, subsite, options[:comments]) unless options[:skip_js]
          inject_css_require(name, subsite, options[:comments]) unless options[:skip_css]
          inject_dryml_include(name, subsite, options[:comments]) unless options[:skip_dryml]
        end

        return need_update
      end

      def inject_js_require(name, subsite, comments)
        application_file = "app/assets/javascripts/#{subsite}.js"
        pattern          = /\/\/=(?!.*\/\/=).*?$/m

        unless exists?(application_file)
          application_file = "#{application_file}.coffee"
          pattern          = /#=(?!.*#=).*?$/m
        end

        raise Thor::Error, "Couldn't find either #{subsite}.js or #{subsite}.js.coffee files!" unless exists?(application_file)

        inject_into_file application_file, :before=>pattern do
          line = "//= require #{name}\n"
          line = "//\n// #{comments}\n#{line}" if comments
          line
        end
      end

      def inject_css_require(name, subsite, comments)
        application_file = "app/assets/stylesheets/#{subsite}.css"
        opts = {:before => /\*=(?!.*\*=).*?$/m}

        raise Thor::Error, "Couldn't find #{subsite}.css!" unless exists?(application_file)

        inject_into_file application_file, opts do
          line = "*= require #{name}\n "
          line = "*\n * #{comments}\n #{line}" if comments
          line
        end
      end

      def inject_dryml_include(name, subsite, comments)
        subsite = "#{subsite}_site" unless subsite=="application"
        application_file = "app/views/taglibs/#{subsite}.dryml"
        pattern          = /\<include gem=.*?\>(?!.*\<include gem=.*?\>).*?\n/m

        raise Thor::Error, "Couldn't find #{subsite}.dryml!" unless exists?(application_file)

        inject_into_file application_file, :after=>pattern do
          line = "\n<include gem='#{name}'/>\n"
          line = "\n<%# #{comments} %>#{line}" if comments
          line
        end
      end


      def exists?(file)
        File.exist?(File.join(destination_root, file))
      end

    end
  end
end

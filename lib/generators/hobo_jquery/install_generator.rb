module HoboJquery
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../../../..', __FILE__)

      desc "Installs javascript and css files for hobo-jquery, jquery and jquery-ui into public/"
      def install
        base_pathname = Pathname.new(File.expand_path('../../../../public', __FILE__))
        Dir[File.expand_path('../../../../public/**/*.*', __FILE__)].each do |fn|
          rfn=Pathname.new(fn).relative_path_from(base_pathname)
          copy_file "public/#{rfn}", "public/#{rfn}"
        end


        base_pathname = Pathname.new(File.expand_path('../../../../jquery', __FILE__))
        Dir[File.expand_path('../../../../jquery/**/*.*', __FILE__)].each do |fn|
          rfn=Pathname.new(fn).relative_path_from(base_pathname)
          copy_file "jquery/#{rfn}", "public/#{rfn}"
        end
      end
    end
  end
end

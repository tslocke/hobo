require 'find'

class HoboRapidGenerator < Hobo::Generator

  def manifest
    record do |m|
      m.file "hobo_rapid.js", "public/javascripts/hobo_rapid.js"
      create_all(m, "themes/default/public", "public/hobothemes/default")
      create_all(m, "themes/default/views", "app/views/hobolib/themes/default")
    end
  end

end

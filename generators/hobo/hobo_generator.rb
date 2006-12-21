class HoboGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory File.join("app/views/hobolib")
      m.directory File.join("app/views/hobolib/themes")
      m.directory File.join("public/hobothemes")
      m.file "application.dryml", File.join("app/views/hobolib/application.dryml")
      m.file "guest.rb", File.join("app/models/guest.rb")
    end
  end

end

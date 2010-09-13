ActionMailer::Base.module_eval do

  def app_name
    Rails.application.config.hobo.app_name
  end

end

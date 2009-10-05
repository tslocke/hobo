class <%= class_name -%>Mailer < ActionMailer::Base
  
  def forgot_password(user, key)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host
    @subject    = "#{app_name} -- forgotten password"
    @body       = { :user => user, :key => key, :host => host, :app_name => app_name }
    @recipients = user.email_address
    @from       = "no-reply@#{host}"
    @sent_on    = Time.now
    @headers    = {}
  end
<% if invite_only? -%>
  
  def invite(user, key)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host
    # FIXME - nasty hack 
    app_name.remove!(/ - Admin$/)
    @subject    = "Invitation to #{app_name}"
    @body       = { :user => user, :key => key, :host => host, :app_name => app_name }
    @recipients = user.email_address
    @from       = "no-reply@#{host}"
    @sent_on    = Time.now
    @headers    = {}
  end
<% end -%>

end

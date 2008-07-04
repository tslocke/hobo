class Hobo::DevController < ActionController::Base

  hobo_controller

  before_filter :developer_modes_only
  
  def set_current_user
    model = params[:model] || Hobo::User.default_user_model
    self.current_user = if params[:login]
                          model.find(:first, :conditions => {model.login_attribute => params[:login]})
                        else
                          model.find(params[:id])
                        end
    redirect_to(request.env["HTTP_REFERER"] ? :back : home_page)
  end

  private

  def developer_modes_only
    # Belt and braces. In addition to this check, the routes only get
    # defined when developer_features? is true
    render :text => "Permission Denied", :status => 403 unless Hobo.developer_features?
  end

end

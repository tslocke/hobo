class Hobo::DrymlSupportController < ActionController::Base
  
  def edit_source
    `emacsclient -n +#{params[:line]} #{File.join(RAILS_ROOT, params[:file])}`
    render :nothing => true
  end

end

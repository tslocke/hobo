module Hobo

  module UserController

    @user_models = []

    class << self
      attr_reader :user_models
      
      def included(base)
        base.filter_parameter_logging "password"
        user_models << base.model
      end
    end
    
    def login; hobo_login; end
    
    def signup; hobo_signup; end
    
    def logout; hobo_logout; end
    
    def hobo_login(options={})
      options = options.reverse_merge(:success_notice => "You have logged in.",
                                      :failure_notice => "You did not provide a valid login and password.",
                                      :redirect_to => {:action => "index"})
      
      if request.post?
        user = model.authenticate(params[:login], params[:password])
        if user
          self.current_user = user
          if params[:remember_me] == "1"
            current_user.remember_me
            create_auth_cookie
          end
          redirect_back_or_default(options[:redirect_to])
          flash[:notice] = options[:success_notice]
        else
          flash[:notice] = options[:failure_notice]
          hobo_render
        end
      else
        hobo_render
      end
    end

    
    def hobo_signup(options={})
      options = options.reverse_merge(:notice => "Thanks for signing up!",
                                      :redirect_to => {:action => "index"})
      if request.post?
        begin
          @user = model.new(params[:user])
          @this = @user
          @user.save!
          self.current_user = @user
          redirect_back_or_default(options[:redirect_to])
          flash[:notice] = options[:notice]
        rescue ActiveRecord::RecordInvalid
          hobo_render
        end
      else
        hobo_render
      end
    end

    
    def hobo_logout(options={})
      options = options.reverse_merge(:notice => "You have been logged out.",
                                      :redirect_to => {:action => "index"})
        
      current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = options[:notice]
      redirect_back_or_default(options[:redirect_to])
    end
    
  end
  
end

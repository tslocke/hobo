module Hobo

  module UserController

    @user_models = []

    class << self
      attr_reader :user_models
      
      def included(base)
        base.filter_parameter_logging "password"
        base.skip_before_filter :login_required, :only => [:login]
        user_models << base.model
      end
    end
    
    def login; hobo_login; end
    
    def signup; hobo_signup; end
    
    def logout; hobo_logout; end
    
    def hobo_login(options={})
      options = LazyHash.new(options)
      options.reverse_merge!(:success_notice => "You have logged in.",
                             :failure_notice => "You did not provide a valid #{model.login_attr.to_s.titleize.downcase} and password.",
                             :disabled_notice => "You account is not currently available.")
      
      if request.post?
        user = model.authenticate(params[:login], params[:password])
        if user.nil?
          flash[:notice] = options[:failure_notice]
        else
          old_user = current_user
          self.current_user = user
          
          # If supplied, a block can be used to test if this user is
          # allowed to log in (e.g. the account may be disabled)
          if block_given? && !yield
            # block returned false - cancel this login
            self.current_user = old_user
            flash[:notice] ||= options[:disabled_notice]
          else
            if params[:remember_me] == "1"
              current_user.remember_me
              create_auth_cookie
            end
            flash[:notice] ||= options[:success_notice]
            redirect_back_or_default(options[:redirect_to] || home_page) unless performed?
          end
        end
      end

      hobo_render unless performed?
    end

    
    def hobo_signup(&b)
      if request.post?
        @user = model.new(params[model.name.underscore])
        @this = @user
        save_and_set_status!(@user)
        self.current_user = @user if valid?
        response_block(&b) or
          if valid?
            flash[:notice] ||= "Thanks for signing up!"
            redirect_back_or_default(home_page)
          elsif invalid?
            hobo_render
          elsif not_allowed?
            permission_denied
          end
      else
        @this = @user = model.new
        yield if block_given?
        hobo_render unless performed?
      end
    end

    
    def hobo_logout(options={})
      options = options.reverse_merge(:notice => "You have been logged out.",
                                      :redirect_to => base_url)
        
      current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      yield if block_given?
      flash[:notice] ||= options[:notice]
      redirect_back_or_default(options[:redirect_to]) unless performed?
    end
    
  end
  
end

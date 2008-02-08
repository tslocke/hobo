module Hobo

  module UserController

    @user_models = []

    class << self
      attr_reader :user_models
      
      def included(base)
        base.class_eval do 
          filter_parameter_logging "password"
          skip_before_filter :login_required, :only => [:login, :signup]
          
          include_taglib "rapid_user_pages", :plugin => "hobo"
          
          show_action :account
          
          alias_method_chain :hobo_update, :account_flash
        end
        
        user_models << base.model
      end
    end
    
    def login; hobo_login; end
    
    def signup; hobo_signup; end
    
    def logout; hobo_logout; end
    
    private
    
    def hobo_login(options={})
      options = LazyHash.new(options)
      login_attr = model.login_attribute.to_s.titleize.downcase
      options.reverse_merge!(:success_notice => "You have logged in.",
                             :failure_notice => "You did not provide a valid #{login_attr} and password.")
      
      if request.post?
        user = model.authenticate(params[:login], params[:password])
        if user.nil?
          flash[:error] = options[:failure_notice]
        else
          old_user = current_user
          self.current_user = user
          
          # If supplied, a block can be used to test if this user is
          # allowed to log in (e.g. the account may be disabled)
          account_available = block_given? ? yield : true

          if !account_available
            # block returned false - cancel this login
            self.current_user = old_user
            render :action => :account_disabled unless performed?
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
          end
      else
        @this = @user = model.new
        yield if block_given?
      end
    end

    
    def hobo_logout(options={})
      options = options.reverse_merge(:notice => "You have logged out.",
                                      :redirect_to => base_url)

      logout_current_user
      yield if block_given?
      flash[:notice] ||= options[:notice]
      redirect_back_or_default(options[:redirect_to]) unless performed?
    end
    
    
    def hobo_update_with_account_flash(*args)
      hobo_update_without_account_flash(*args) do
        flash[:notice] = "Changes to your account were saved" if valid? && @this == current_user
        yield if block_given?
      end
    end
    
    private
    
    def logout_current_user
      if logged_in?
        current_user.forget_me
        cookies.delete :auth_token
        reset_session
        self.current_user = nil
      end
    end
    
  end
  
end

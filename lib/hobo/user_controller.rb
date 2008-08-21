module Hobo

  module UserController

    class << self
      def included(base)
        base.class_eval do
          extend ClassMethods
          
          class << self
            alias_method_chain :available_auto_actions, :user_actions
            alias_method_chain :def_auto_actions, :user_actions
          end
          
          filter_parameter_logging "password"
          skip_before_filter :login_required, :only => [:login, :signup, :forgot_password, :reset_password_page, :reset_password]

          include_taglib "rapid_user_pages", :plugin => "hobo"

          show_action :account

          alias_method_chain :hobo_update, :account_flash
        end
        
      end

          
    end
    
    module ClassMethods

      def available_auto_actions_with_user_actions
        available_auto_actions_without_user_actions + 
          [:login, :signup, :logout, :forgot_password, :reset_password]
      end

      
      def def_auto_actions_with_user_actions
        def_auto_actions_without_user_actions
        
        class_eval do
          def login; hobo_login;                     end if include_action?(:login)
          def signup; hobo_signup;                   end if include_action?(:signup)
          def logout; hobo_logout;                   end if include_action?(:logout)
          def forgot_password; hobo_forgot_password; end if include_action?(:forgot_password)
          def reset_password; hobo_reset_password;   end if include_action?(:reset_password)
        end
      end

    end


    private

    def hobo_login(options={})
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
      creator_page_action(:signup) do
        response_block(&b) or if valid?
                                self.current_user = this
                                flash[:notice] = "Thanks for signing up!"
                                redirect_back_or_default(home_page)
                              end
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


    def hobo_forgot_password
      if request.post?
        user = model.find_by_email_address(params[:email_address])
        if user && (!block_given? || yield(user))
          Hobo::Controller.request_host = request.host_with_port
          Hobo::Controller.app_name = call_tag(:app_name)
          user.lifecycle.request_password_reset(:nobody)
        end
        render_tag :forgot_password_email_sent_page
      end
    end


    def hobo_reset_password(&b)
      transition_action :reset_password do
        response_block(&b) or if valid?
                                self.current_user = this
                                flash[:notice] = "Your password has been reset"
                                redirect_to home_page
                              end
      end
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

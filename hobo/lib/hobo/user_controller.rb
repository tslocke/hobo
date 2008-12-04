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

          alias_method_chain :hobo_update, :account_flash
        end
        
      end

          
    end
    
    module ClassMethods

      def available_auto_actions_with_user_actions
        available_auto_actions_without_user_actions + 
          [:login, :signup, :logout, :forgot_password, :reset_password, :account]
      end

      
      def def_auto_actions_with_user_actions
        def_auto_actions_without_user_actions

        class_eval do
          def login; hobo_login;                         end if include_action?(:login)
          def logout; hobo_logout;                       end if include_action?(:logout)
          def do_signup; hobo_do_signup                  end if include_action?(:do_signup)
          def forgot_password; hobo_forgot_password;     end if include_action?(:forgot_password)
          def do_reset_password; hobo_do_reset_password; end if include_action?(:do_reset_password)
          show_action :account                               if include_action?(:account)
        end
      end

    end


    private

    def hobo_login(options={})
      (redirect_to home_page; return) if logged_in?

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
          
          yield if block_given?

          if !user.account_active?
            # account not activate - cancel this login
            self.current_user = old_user
            render :action => :account_disabled unless performed?
          else
            if params[:remember_me].present?
              current_user.remember_me
              create_auth_cookie
            end
            flash[:notice] ||= options[:success_notice]
            redirect_back_or_default(options[:redirect_to] || home_page) unless performed?
          end
        end
      end
    end


    def hobo_do_signup(&b)
      do_creator_action(:signup) do
        if valid?
          flash[:notice] = "Thanks for signing up!"
          flash[:notice] << " You must activate your account before you can log in. Please check your email." unless this.account_active?
        end
        response_block(&b) or if valid?
                                self.current_user = this if this.account_active?
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
          user.lifecycle.request_password_reset!(:nobody)
        end
        render_tag :forgot_password_email_sent_page
      end
    end


    def hobo_do_reset_password(&b)
      do_transition_action :reset_password do
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

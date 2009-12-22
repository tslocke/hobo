require 'digest/sha1'

module Hobo

  module User

    @user_models = []

    def self.default_user_model
      @user_models.first._?.constantize
    end

    AUTHENTICATION_FIELDS = [:salt, :crypted_password, :remember_token, :remember_token_expires_at]

    # Extend the base class with AuthenticatedUser functionality
    # This includes:
    # - plaintext password during login and encrypted password in the database
    # - plaintext password validation
    # - login token for rembering a login during multiple browser sessions
    def self.included(base)
      @user_models << base.name

      base.extend(ClassMethods)

      base.class_eval do

        fields do
          crypted_password          :string, :limit => 40
          salt                      :string, :limit => 40
          remember_token            :string
          remember_token_expires_at :datetime
        end

        validates_confirmation_of :password,              :if => :new_password_required?
        password_validations
        validate :validate_current_password_when_changing_password

        # Virtual attributes for setting and changing the password
        # note that :password_confirmation= is also defined by
        # validates_confirmation_of, so this line must follow any
        # validates_confirmation_of statements.
        # https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/530
        attr_accessor :current_password, :password, :password_confirmation, :type => :password

        before_save :encrypt_password
        after_save :stash_current_password

        never_show *AUTHENTICATION_FIELDS

        attr_protected *AUTHENTICATION_FIELDS


      end
    end

    # Additional classmethods for authentication
    module ClassMethods

      # Validation of the plaintext password
      def password_validations
        validates_length_of :password, :within => 4..40, :if => :new_password_required?
      end

      def login_attribute=(attr, validate=true)
        @login_attribute = attr = attr.to_sym
        unless attr == :login
          alias_attribute(:login, attr)
          declare_attr_type(:login, attr_type(attr)) if table_exists? # this breaks if the table doesn't exist
        end

        if validate
          validates_length_of     attr, :within => 3..100
          validates_uniqueness_of attr, :case_sensitive => false
        end
      end

      inheriting_cattr_reader :login_attribute


      # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
      def authenticate(login, password)
        u = find(:first, :conditions => ["#{@login_attribute} = ?", login]) # need to get the salt

        if u && u.authenticated?(password)
          if u.respond_to?(:last_login_at) || u.respond_to?(:login_count)
            u.last_login_at = Time.now if u.respond_to?(:last_login_at)
            u.login_count = (u.login_count.to_i + 1) if u.respond_to?(:login_count)
            u.save
          end
          u
        else
          nil
        end
      end

      # Encrypts some data with the salt.
      def encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end

    end

    def account_active?
      lifecycle.active_state?
    end

    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password, salt)
    end

    # Check if the encrypted passwords match
    def authenticated?(password)
      crypted_password == encrypt(password)
    end

    # Do we still need to remember the login token, or has it expired?
    def remember_token?
      remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      self.remember_token_expires_at = 2.weeks.from_now.utc
      self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
      save(false)
    end

    # Expire the login token, resulting in a forced login next time.
    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token            = nil
      save(false)
    end

    def guest?
      false
    end

    def signed_up?
      true
    end

    protected
    # Before filter that encrypts the password before having it stored in the database.
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if salt.blank?
      self.crypted_password = encrypt(password)
    end

    # after filter that sets current_password so we can pass
    # validate_current_password_when_changing_password if you save
    # again.  See
    # https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/590
    def stash_current_password
      @current_password ||= password
    end

    def changing_password?
      !new_record? && !lifecycle_changing_password? &&
        (current_password.present? || password.present? || password_confirmation.present?)
    end
    
    
    def lifecycle_changing_password?
      self.class.has_lifecycle? && lifecycle.active_step && :password.in?(lifecycle.active_step.parameters)
    end

    # Is a new password (and confirmation) required? (i.e. signing up or changing password)
    def new_password_required?
      lifecycle_changing_password? || changing_password?
    end


    def validate_current_password_when_changing_password
      changing_password? && !authenticated?(current_password) and errors.add :current_password, Hobo::Translations.ht("hobo.messages.current_password_is_not_correct", :default => "is not correct")
    end

  end

end

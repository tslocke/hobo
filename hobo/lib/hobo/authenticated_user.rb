require 'digest/sha1'

module Hobo

  module AuthenticatedUser

    # Extend the base class with AuthenticatedUser functionality
    # This includes:
    # - plaintext password during login and encrypted password in the database
    # - plaintext password validation
    # - login token for rembering a login during multiple browser sessions
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        fields do
          crypted_password          :string, :limit => 40
          salt                      :string, :limit => 40
          remember_token            :string
          remember_token_expires_at :datetime
        end
        
        # Virtual attribute for the unencrypted password
        attr_accessor :password

        validates_presence_of     :password,                   :if => :password_required?
        validates_presence_of     :password_confirmation,      :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?
      
        before_save :encrypt_password
        
        never_show :salt, :crypted_password, :remember_token, :remember_token_expires_at
        
        set_field_type :password => :password, :password_confirmation => :password
        
        password_validations
      end
    end

    # Additional classmethods for AuthenticatedUser
    module ClassMethods
      
      # Validation of the plaintext password
      def password_validations
        validates_length_of :password, :within => 4..40, :if => :password_required?
      end
      
      def set_login_attr(attr)
        @login_attr = attr = attr.to_sym
        alias_attribute(:login, attr) unless attr == :login
        
        if block_given?
          yield
        else 
          validates_presence_of   attr
          validates_length_of     attr, :within => 3..100
          validates_uniqueness_of attr, :case_sensitive => false
        end
      end

      # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
      def authenticate(login, password)
        u = find(:first, :conditions => ["#{@login_attr} = ?", login]) # need to get the salt
        
        if u && u.authenticated?(password)
          if u.respond_to?(:last_login_at) || u.respond_to?(:logins_count)
            u.last_login_at = Time.now if u.respond_to?(:last_login_at)
            u.logins_count = (u.logins_count.to_i + 1) if u.respond_to?(:logins_count)
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

    protected
    # Before filter that encrypts the password before having it stored in the database.
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    # Is a password required for login? (or do we have an empty password?)
    def password_required?
      (crypted_password.blank? && password != nil) || !password.blank?
    end
    
  end

end

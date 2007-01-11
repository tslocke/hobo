require 'digest/sha1'

module Hobo

  module AuthenticatedUser

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
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

    module ClassMethods
      
      def password_validations
        validates_length_of :password, :within => 4..40, :if => :password_required?
      end
      
      def set_login_attr(attr)
        @login_attr = attr = attr.to_sym
        validates_presence_of     attr
        validates_length_of       attr, :within => 3..100
        validates_uniqueness_of   attr, :case_sensitive => false
        
        alias_attribute(:login, attr) unless attr == :login
      end

      # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
      def authenticate(login, password)
        u = find(:first, :conditions => ["#{@login_attr} = ?", login]) # need to get the salt
        u && u.authenticated?(password) ? u : nil
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

    def authenticated?(password)
      crypted_password == encrypt(password)
    end

    def remember_token?
      remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      self.remember_token_expires_at = 2.weeks.from_now.utc
      self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
      save(false)
    end

    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token            = nil
      save(false)
    end

    protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

  end

end

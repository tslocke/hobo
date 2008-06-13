
class Test::Unit::TestCase

  def self.fixture_objects(model, *names)
    fixtures model
    names.each do |name|
      class_eval "def #{name}; #{model}(:#{name}); end"
    end
  end

  protected

  module HoboTesting

    class HoboHelpers

      def urlb
        "http://example.com"
      end
    end

    attr_reader :current_user

    def is_redirected_to(x)
      url = x.is_a?(String) ? x : object_url(x)
      assert_response :redirect
      assert_redirected_to(url)
      follow_redirect!
      assert_response :success
    end

    def logs_in_as(user, password)
      @current_user = user
      post login_url(user), :login => user.login, :password => password
      assert_response :redirect, "#{user.login} failed to log in"
      get homepage_url
      assert_response :success
    end

    def visits(obj, action=nil, params={})
      get object_url(obj, action, params)
      assert_response :success
    end

    def cant_visit(obj, action=nil)
      get object_url(obj, action)
      assert_response :forbidden
    end

    def creates(klass, params)
      replace_objects_in_params!(params)
      post object_url(klass), klass.name.underscore => params
      new_obj = assigns["this"]
      flunk "validation errors: #{new_obj.errors.full_messages.join("\n")}" unless new_obj.errors.empty?
      assert_response :redirect
      new_obj
    end

    def deletes(object)
      post object_url(object, "destroy")
      assert_raise(ActiveRecord::RecordNotFound) { object.class.find(object.id) }
      assert_response :redirect
    end

    def cant_create(klass, params)
      replace_objects_in_params!(params)
      post object_url(klass), klass.name.underscore => params
      assert_response :forbidden
    end

    def can_see(s)
      assert_select("body", Regexp.new(s.split.map { |w| Regexp.escape(w) }.join("\s*")),
                    current_should("be able to see: #{s}"))
    end

    alias_method :sees, :can_see

    def cant_see(s)
      assert_select("body", { :text => Regexp.new(s.split.map { |w| Regexp.escape(w) }.join("\s*")), :count => 0 },
                    current_should("not be able to see: #{s}"))
    end

    def creates_and_visits(klass, params)
      new_obj = creates(klass, params)
      visits(new_obj)
      new_obj
    end

    def calls_method(object, method, params={})
      post object_url(object, method), params
      assert_response :success
    end

    def current_should(s)
      "#{current_user.login} should #{s}"
    end

    def object_url(obj, action=nil, *param_hashes)
      HoboHelpers.new.send(:object_url, obj, action, *param_hashes)
    end

    def replace_objects_in_params!(hash)
      hash.each do |k,v|
        if v.is_a? ActiveRecord::Base
          hash[k] = "@" + v.typed_id
        elsif v.is_a? Hash
          replace_objects_in_params!(v)
        end
      end
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(HoboTesting)
      session_opened(sess) if respond_to? :session_opened
      yield sess if block_given?
    end
  end

  def new_session_as(person, password)
    new_session do |sess|
      sess.logs_in_as(person, password)
      yield sess if block_given?
    end
  end

end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "user permissions" do
    setup do
      @admin = create(:admin)
      @user = create(:user)
      @user2 = create(:user, :name => "User 2", :email_address => "user2@example.com")
    end

    should "only let the admin change the admin flag" do
      assert_nothing_raised { @user.user_update_attributes(@admin, {:administrator => true}) }
      assert_equal true, @user.administrator
      assert_raise(Hobo::PermissionDeniedError) { @user.user_update_attributes(@user, {:administrator => false}) }
    end

    should "only let an admin or the user change their email address" do
      assert_nothing_raised { @user.user_update_attributes(@admin, {:email_address => "foo@example.com"}) }
      assert_nothing_raised { @user.user_update_attributes(@user, {:email_address => "bar@example.com"}) }
      assert_raise(Hobo::PermissionDeniedError) { @user.user_update_attributes(@user2, {:email_address => "baz@example.com"}) }
    end
  end
end

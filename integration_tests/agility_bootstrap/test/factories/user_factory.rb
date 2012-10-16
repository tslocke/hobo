FactoryGirl.define do
  factory :user do
    name 'Test User'
    email_address 'test@example.com'
    administrator false
    password "test123"
    state "active"
  end

  factory :admin, :class => User do
    name 'Admin User'
    email_address 'admin@example.com'
    administrator true
    password "test123"
    state "active"
  end
end

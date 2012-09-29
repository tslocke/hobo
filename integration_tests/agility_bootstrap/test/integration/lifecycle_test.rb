# -*- coding: utf-8 -*-
require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'database_cleaner'
#require 'ruby-debug'

Capybara.app = Agility::Application
Capybara.default_driver = :rack_test
DatabaseCleaner.strategy = :truncation

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

class LifecycleTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.start
    @admin = create(:admin)
    @verify_list = []
  end

  teardown do
    DatabaseCleaner.clean
  end

  test "foos lifecycles" do
    Capybara.current_driver = :selenium_chrome
    visit root_path

    # log in as Administrator
    click_link "Log out" rescue Capybara::ElementNotFound
    click_link "Login"
    fill_in "login", :with => "admin@example.com"
    fill_in "password", :with => "test123"
    click_button "Login"
    assert has_content?("Logged in as Admin User")

    visit "/foos/new"
    click_button "Create Foo"
    click_button "Trans1"
    uncheck "foo[v]"
    sleep 1
    click_button "Trans1"
    assert has_content?("v must be true")
    check "foo[v]"
    click_button "Trans1"
    click_button "Trans2"

  end
end

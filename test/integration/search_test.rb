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

class SearchTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.start
    @admin = create(:admin)
    @project = create(:project, :name => "First Project", :owner => @admin)
    @s1 = create(:story, :project => @project, :title => "First Story", :body => "First Story")
  end

  teardown do
    DatabaseCleaner.clean
  end

  def wait_for_updates_to_finish
    while page.evaluate_script("$(document).hjq('numUpdates')").to_i > 0
      sleep 0.1
    end
  end

  test "search" do
    Capybara.current_driver = :selenium
    visit root_path

    # log in as Administrator
    click_link "Log out" rescue Capybara::ElementNotFound
    click_link "Login"
    fill_in "login", :with => "admin@example.com"
    fill_in "password", :with => "test123"
    click_button "Login"
    assert has_content?("Logged in as Admin User")

    visit root_path

    fill_in "query", :with => "First"
    find("input[name=query]").native.send_key(:enter)
    assert has_content?("Search Results")
    assert find("#search-results-part").has_content?("First Project")
    assert find("#search-results-part").has_content?("First Story")

  end
end

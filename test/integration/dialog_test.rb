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

class DialosgTest < ActionDispatch::IntegrationTest
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

  test "dialog" do
    Capybara.current_driver = :selenium_chrome
    visit root_path

    # log in as Administrator
    click_link "Log out" rescue Capybara::ElementNotFound
    click_link "Login"
    fill_in "login", :with => "admin@example.com"
    fill_in "password", :with => "test123"
    click_button "Login"
    assert has_content?("Logged in as Admin User")

    visit "/projects/#{@project.id}/dialog_test"

    click_button "New Story"
    fill_in "story[title]", :with => "Another Story"
    fill_in "story[body]", :with => "body"
    click_button "ok"
    wait_for_updates_to_finish

    assert find("#stories tr:eq(2) td:first").has_content?("Another Story")
  end
end

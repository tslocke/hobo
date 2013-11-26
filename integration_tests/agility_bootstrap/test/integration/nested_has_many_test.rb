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

class NestedHasManyTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.start
    @admin = create(:admin)
    @verify_list = []
    @discussion = create(:story_status, :name => "discussion")
    @implementation = create(:story_status, :name => "implementation")
    @project = create(:project, :name => "First Project", :owner => @admin)
    @s1 = create(:story, :project => @project, :title => "First Story", :body => "First Story", :status => @discussion)
    @s2 = create(:story, :project => @project, :title => "Second story for first project", :body => "Second story for first project (body)", :status => nil)
    @t1 = create(:task, :story => @s1, :description => "First Task", :position => 1)
  end

  teardown do
    DatabaseCleaner.clean
  end

  test "nested has_many" do
    Capybara.current_driver = :selenium_chrome
    visit root_path

    # Resize the window so Bootstrap shows Login button
    Capybara.current_session.driver.browser.manage.window.resize_to(1024,700)

    # log in as Administrator
    click_link "Log out" rescue Capybara::ElementNotFound
    click_link "Login"
    fill_in "login", :with => "admin@example.com"
    fill_in "password", :with => "test123"
    click_button "Login"
    assert has_content?("Logged in as Admin User")

    visit "/projects/#{@project.id}/nested_has_many_test"

    # second story has no tasks but minimal="1", so should have empty task
    assert_equal find("#project_stories_1_tasks_0_description").value, ""
    assert find("#project_stories_1_tasks_0_add").visible?
    assert !find("#project_stories_1_tasks_0_remove").visible?

    # first story only has a single task
    assert find("#project_stories_0_tasks_0_add").visible?
    assert !find("#project_stories_0_tasks_0_remove").visible?

    # verify button customized
    assert find("#project_stories_0_remove").has_text?("Remove Story")

    # verify fields customized
    assert has_no_css?("#project_stories_0_tasks_0_position")

    # verify add inner
    click_button "project_stories_0_tasks_0_add"
    assert has_field?("project_stories_0_tasks_1_description") #wait
    fill_in "project_stories_0_tasks_1_description", :with => "Second task for first story"
    assert !find("#project_stories_0_tasks_0_add").visible?
    assert find("#project_stories_0_tasks_0_remove").visible?
    assert find("#project_stories_0_tasks_1_add").visible?
    assert find("#project_stories_0_tasks_1_remove").visible?

    sleep 1
    click_button "project_stories_0_tasks_1_add"
    assert has_field?("project_stories_0_tasks_2_description") #wait
    fill_in "project_stories_0_tasks_2_description", :with => "Third task for first story"
    assert !find("#project_stories_0_tasks_1_add").visible?
    assert find("#project_stories_0_tasks_1_remove").visible?
    assert find("#project_stories_0_tasks_2_add").visible?
    assert find("#project_stories_0_tasks_2_remove").visible?

    # verify save
    click_button "Save"
    assert find(".table-plus tr:first-child td.tasks-count-view span").has_text?("3")
    visit "/projects/#{@project.id}/nested_has_many_test"

    # verify remove inner
    click_button "project_stories_0_tasks_1_remove"
    assert has_no_field?("project_stories_0_tasks_2_description") #wait
    sleep 1.0
    assert_equal find("#project_stories_0_tasks_1_description").value, "Third task for first story"
    assert !find("#project_stories_0_tasks_0_add").visible?
    assert find("#project_stories_0_tasks_0_remove").visible?
    assert find("#project_stories_0_tasks_1_add").visible?
    assert find("#project_stories_0_tasks_1_remove").visible?

    click_button "project_stories_0_tasks_0_remove"
    assert has_no_field?("project_stories_0_tasks_1_description") #wait
    sleep 1.0
    assert_equal find("#project_stories_0_tasks_0_description").value, "Third task for first story"
    assert find("#project_stories_0_tasks_0_add").visible?
    assert !find("#project_stories_0_tasks_0_remove").visible?

    # verify add outer
    click_button "project_stories_1_add"
    assert has_field?("project_stories_2_tasks_0_description") #wait
    assert_equal find("#project_stories_2_tasks_0_description").value, ""
    assert find("#project_stories_2_tasks_0_add").visible?
    assert !find("#project_stories_2_tasks_0_remove").visible?
    click_button "project_stories_2_tasks_0_add"
    assert !find("#project_stories_2_tasks_0_add").visible?
    assert find("#project_stories_2_tasks_0_remove").visible?
    assert find("#project_stories_2_tasks_1_add").visible?
    assert find("#project_stories_2_tasks_1_remove").visible?
    fill_in "project_stories_2_tasks_1_description", :with => "Third story Second task"

    #verify remove outer
    click_button "project_stories_0_remove"
    page.driver.browser.switch_to.alert.accept
    assert has_no_field?("project_stories_2_title") #wait
    sleep 1.0
    assert_equal find("#project_stories_0_title").value, "Second story for first project"

    click_button "project_stories_0_remove"
    page.driver.browser.switch_to.alert.accept
    assert has_no_field?("project_stories_1_title") #wait
    sleep 1.0
    assert_equal find("#project_stories_0_tasks_1_description").value, "Third story Second task"

    click_button "project_stories_0_remove"
    page.driver.browser.switch_to.alert.dismiss
    sleep 1 # because the following would always be true even if the alert failed.
    assert_equal find("#project_stories_0_tasks_1_description").value, "Third story Second task"

    click_button "project_stories_0_remove"
    page.driver.browser.switch_to.alert.accept
    assert has_no_field?("project_stories_0_title") #wait
    sleep 1.0
    assert has_no_css?("#project_stories_0_tasks_1_description")

    assert find("#project_stories_-1_empty").visible?

  end
end

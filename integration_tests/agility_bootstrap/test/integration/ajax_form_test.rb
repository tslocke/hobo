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

class AjaxFormTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Factory::Syntax::Methods

  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.start
    @admin = create(:admin)
    @project = create(:project)
    @s1 = create(:story, :project => @project)
    @s2 = create(:story, :project => @project, :title => "Sample Story 2")
  end

  teardown do
    DatabaseCleaner.clean
  end

  def wait_for_updates_to_finish
    while page.evaluate_script("$(document).hjq('numUpdates')").to_i > 0
      sleep 0.1
    end
  end

  def wait_for_ajax(timeout = Capybara.default_wait_time)
    sleep 0.1
    while page.evaluate_script 'jQuery.active == 0'
      sleep 0.1
    end
  end


  test "ajax forms" do
    Capybara.current_driver = :selenium_chrome
    Capybara.default_wait_time = 10
    visit root_path

    # Resize the window so Bootstrap shows Login button
    Capybara.current_session.driver.browser.manage.window.resize_to(1024,700)

    # log in as Administrator
    click_link "Login"
    fill_in "login", :with => "admin@example.com"
    fill_in "password", :with => "test123"
    click_button "Login"
    assert has_content?("Logged in as Admin User")

    # define statuses
    visit "/story_statuses/index2"

    # verify that qunit tests have passed.
    assert has_content?("0 failed.")

    find("#form1").fill_in("story_status_name", :with => "foo1")
    find("#form1").click_button("new")
    assert find(".statuses table tbody tr:first .story-status-name").has_text?("foo1")
    # wait_for_updates_to_finish  # we don't need this every time, but if we don't throw it in occasionally, things do stop working

    find("#form2").fill_in("story_status_name", :with => "foo2")
    sleep 0.25
    find("#form2").click_button("new")
    sleep 0.25
    assert find(".statuses table tbody tr:nth-child(2) .story-status-name").has_text?("foo2")
    wait_for_updates_to_finish

    find("#form3").fill_in("story_status_name", :with => "foo3")
    find("#form3").click_button("new")
    assert find(".statuses table tbody tr:nth-child(3) .story-status-name").has_text?("foo3")
    # wait_for_updates_to_finish

    find("#form4").fill_in("story_status_name", :with => "foo4")
    find("#form4").click_button("new")
    assert find(".statuses table tbody tr:nth-child(4) .story-status-name").has_text?("foo4")
    wait_for_updates_to_finish

    find(".statuses table tr:first .delete-button").click
    page.driver.browser.switch_to.alert.accept
    assert has_no_content?("foo1")   # waits for ajax to finish
    assert_equal 3, all(".statuses table tbody tr").length

    visit "/story_statuses/index3"
    find(".statuses li:first .delete-button").click
    page.driver.browser.switch_to.alert.accept
    assert has_no_content?("foo2")   # waits for ajax to finish
    assert_equal 2, all(".statuses li").length
    assert has_content?("There are 2 Story statuses")

    visit "/story_statuses/index4"
    find(".statuses li:first .delete-button").click
    page.driver.browser.switch_to.alert.accept
    visit "/story_statuses/index4" # Index4 delete-buttons have Ajax disabled (in-place="&false")
    assert_equal 1, all(".statuses li").length

    find(".statuses li:first .delete-button").click
    page.driver.browser.switch_to.alert.accept
    visit "/story_statuses/index4" # Index4 delete-buttons have Ajax disabled (in-place="&false")
    assert has_no_content?("foo4")   # waits for ajax to finish
    assert_equal 0, all(".statuses li").length
    assert has_content?("No records to display")

    visit "/projects/#{@project.id}/show2"
    assert_not_equal "README", find(".report-file-name-field .controls").text
    attach_file("project[report]", File.join(::Rails.root, "README"))
    click_button "upload new report"
    sleep 0.5
    assert find(".report-file-name-field .controls").has_content?("README")

    # these should be set by show2's custom-scripts
    assert find(".events").has_text?("events: rapid:ajax:before rapid:ajax:success rapid:ajax:complete")
    assert find(".callbacks").has_text?("callbacks: before success complete")

    find(".story.odd").fill_in("story_title", :with => "s1")
    page.execute_script("$('.story.odd form').submit()")
    sleep 0.5
    assert find(".story.odd .view.story-title").has_content?("s1")
    assert find(".story.odd .ixz").has_content?("1")

    find(".story.even").fill_in("story_title", :with => "s2")
    page.execute_script("$('.story.even form').submit()")
    sleep 0.5
    assert find(".story.even .view.story-title").has_content?("s2")
    assert find(".story.even .ixz").has_content?("2")

    # update name without errors-ok should display alert
    visit "/projects/#{@project.id}/show2"
    find("#name-form").fill_in("project_name", :with => "invalid name")
    find("#name-form .submit-button").click
    sleep 1 # wait_for_ajax is blocked by the open dialog!
    page.driver.browser.switch_to.alert.accept

    # update name with errors-ok should display error-messages
    visit "/projects/#{@project.id}/show2"
    find("#name-form-ok").fill_in("project_name", :with => "invalid name")
    find("#name-form-ok .submit-button").click
    assert find("#name-form-ok .error-messages").has_content?("1 error")

  end
end

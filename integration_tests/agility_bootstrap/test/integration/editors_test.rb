# -*- coding: utf-8 -*-
require 'test_helper'
require 'capybara'
require 'capybara/dsl'
require 'database_cleaner'

Capybara.app = Agility::Application
Capybara.default_driver = :rack_test
DatabaseCleaner.strategy = :truncation

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

class EditorsTest < ActionDispatch::IntegrationTest
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

  def use_editor(selector, value, text_value=nil)
    text_value ||= value
    assert find("#{selector} .in-place-edit").has_no_text?(text_value)
    find("#{selector} .in-place-edit").click
    sleep 1
    find("#{selector} input[type=text],#{selector} textarea").set(value)
    find("h2.heading").click # just to get a blur
    sleep 0.5
    assert page.find("#{selector} .in-place-edit").has_text?(text_value)
    @verify_list << { :selector => selector, :value => text_value }
  end

  def wait_for_updates_to_finish
    while page.evaluate_script("$(document).hjq('numUpdates')").to_i > 0
      sleep 0.1
    end
  end


  test "editors" do
    Capybara.current_driver = :selenium_chrome
    Capybara.default_wait_time = 5
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
    click_link "editors"


    use_editor ".i-field .controls", "17"
    use_editor ".f-field .controls", "3.14159"
    use_editor ".dec-field .controls", "12.34"
    use_editor ".s-field .controls", "hello"
    use_editor ".tt-field .controls", "plain text"
    use_editor ".d-field .controls", Date.new(1973,4,8).to_s(:default)
#    use_editor ".dt-view", DateTime.new(1975,5,13,7,7).strftime(I18n.t(:"time.formats.default"))

    use_editor ".tl-field .controls", "_this_ is *textile*", "this is textile"
    use_editor ".md-field .controls", "*this* is **markdown**", "this is markdown"
    use_editor ".hh-field .controls", "<i>this</i> is <b>HTML</b>", "this is HTML"

    find(".bool1-field .controls input[type=checkbox]").click
    @verify_list << { :selector => ".bool1-field .controls", :value => "Yes" }

    find(".bool2-field .controls input[type=checkbox]").click
    wait_for_updates_to_finish
    find(".bool2-field .controls input[type=checkbox]").click
    @verify_list << { :selector => ".bool2-field .controls", :value => "No" }

    find(".es-field .controls select").select("C")
    @verify_list << { :selector => ".es-field .controls", :value => "C" }

    if Capybara.current_driver == :selenium
      fill_in "foo[i]", :with => "17"
      click_button "reload editors"
    else
      find("#bug305i input.foo-i").set("192")
      click_button "reload editors"
      sleep 0.5
      assert find(".i-field .controls .in-place-edit").has_text?("192")

      find(".i-field .controls .in-place-edit").click
      sleep 1
      find(".i-field .controls input[type=text]").set('17')
      find("h2.heading").click # just to get a blur
      assert find(".i-field .controls .in-place-edit").has_text?('17')
    end

    click_link "exit editors"

    @verify_list.each {|v|
      assert_equal v[:value], find(v[:selector]).text, v[:selector]
    }

  end
end

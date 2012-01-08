When /^I render "([^"]*)"$/ do |file|
  file_path = aruba_path(file)
  file_data = File.read(file_path)
  @locals ||= {}
  @taglibs ||= []
  @rendered_dom = Dryml.render(file_data, @locals, file_path, @taglibs)
  Dryml::Template.clear_build_cache
end

When /^I include the taglib "([^"]*)"$/ do |file|
  file_path = aruba_path(file+".dryml")
  template_dir = File.dirname(file_path)
  @taglibs ||= []
  @taglibs << { :src => file, :absolute_template_path => template_dir }
end

Given /^the local variable "([^"]*)" has the value "([^"]*)"$/ do |var, value|
  @locals ||= {}
  @locals[var.to_sym] = value
end


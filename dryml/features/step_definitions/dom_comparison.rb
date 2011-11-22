Then /^the output DOM should be:$/ do |expected_html|
  expected_rendered = ''
  actual_rendered = ''
  formatter = StripFormatter.new
  # wrap in html tag, as REXML gets grumpy if there's more than one root node
  formatter.write(REXML::Document.new("<html>#{expected_html}</html>"), expected_rendered)
  formatter.write(REXML::Document.new("<html>#{@rendered_dom}</html>"), actual_rendered)
  actual_rendered.should eq(expected_rendered)
end


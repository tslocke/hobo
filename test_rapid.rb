lib = File.expand_path('../../../lib', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bundler'
Bundler.setup

require 'active_support'
require 'action_view'
require 'action_controller'
require 'action_mailer'

require 'dryml'
require 'dryml/railtie/template_handler'
require 'rails'
require 'hobo'

require 'rexml/document'
require 'rexml/formatters/default'

require 'English'

# strip whitespace when formatting XML

class StripFormatter < REXML::Formatters::Default

  protected

  def write_text(node, output)
    output << node.to_s.strip
  end

end

def xml_diff(expected_html, received_html)
  expected_rendered = ''
  actual_rendered = ''
  formatter = StripFormatter.new
  # wrap in html tag, as REXML gets grumpy if there's more than one rootnode
  expected_doc = REXML::Document.new("<html>#{expected_html}</html>")
  received_doc = REXML::Document.new("<html>#{received_html}</html>")
  formatter.write(expected_doc, expected_rendered)
  formatter.write(received_doc, actual_rendered)
  diff = ''
  received_doc.write(diff, 2)
  actual_rendered==expected_rendered ? nil : diff[7..-8]
end

Dryml::DrymlDoc.load_taglibs("#{Dir.getwd.to_s}/taglibs").each do |taglib|
  taglib.tag_defs.each do |tagdef|
      comment = tagdef.comment
      while m=comment.try.match(/([[:print:]]*)Giving:\n(.*?)(\n\S)/m)
        description = m[1].strip
        given = m[2].gsub(/\{: .*?\}/, "")
        m=(m[3]+m.post_match).match(/Produces:\n(.*?)(\n\S|\Z)/m)
        expected = m[1].gsub(/\{: .*?\}/, "")
        comment = m[2]+m.post_match
        received = Dryml.render(given, {}, '.', [{:src => 'core', :gem => 'dryml'}, {:src => 'rapid', :gem => 'hobo'}, {:src => 'hobo-jquery', :absolute_template_path => "#{Dir.getwd.to_s}/taglibs"}])
        Dryml::Template.clear_build_cache
        if (diff=xml_diff(expected, received))
          puts "#{description} Error:"
          puts "Given:#{given}"
          puts "Expected:#{expected}"
          puts "But received:\n#{diff.to_s}"
        else
          puts "#{description} OK"
        end
      end
  end
end


module Hobo; end
module Hobo::Dryml
  # Extracts the original definition of a tag from its source file
  # Initially, only extracts from taglibs within HOBO_ROOT
  def self.extract_tag(name)
    base_dir = "#{HOBO_ROOT}/taglibs"
    all_dryml_files = Dir[base_dir + "/**/*.dryml"]
    for file in all_dryml_files
      contents = File.read(file).split("\n")
      start_index, end_index, def_count = nil, contents.length - 1, 0
      contents.each_with_index do |line, index|
        if line =~ /<def tag="#{name}"/
          start_index = index
        end
        if start_index
          def_count += 1 if line =~ /<def/
          def_count -= 1 if line =~ %r{</def}
          if def_count == 0
            end_index = index
            return contents[start_index..end_index].join("\n")
          end
        end
      end
    end
    nil
  end
end

# To run tests, execute this source file
if __FILE__==$0
  require 'test/unit'
  HOBO_ROOT = File.dirname(__FILE__) + "/../../.."

  class TagExtractorTest < Test::Unit::TestCase
    def test_should_find_one_line_tag
      tag_src = Hobo::Dryml.extract_tag('item')
      expected = '<def tag="item"><% scope.items << parameters.default %></def>'
      assert_not_nil(tag_src)
      assert_equal(expected, tag_src)
    end

    def test_should_find_multiline_tag
      tag_src = Hobo::Dryml.extract_tag('image')
      expected = <<-TAG.strip
<def tag="image" attrs="src">
  <img src="\#{base_url}/images/\#{src}" merge-attrs/>
</def>
TAG
      assert_not_nil(tag_src)
      assert_equal(expected, tag_src)
    end

    def test_should_not_find_xxx
      tag_src = Hobo::Dryml.extract_tag('xxx')
      assert_nil(tag_src)
    end
  end
end
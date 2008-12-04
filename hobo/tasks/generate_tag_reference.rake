require 'fileutils'

ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__) + "/../lib"

require 'rexml/xpath'
XPath = REXML::XPath

def tag_title(tag, link=false)
  if tag.is_a? String
    name = tag
    anchor = tag
  else
    for_attr = tag.attributes['for'] and for_decl = %( for=`"#{for_attr}"`)
    name = tag.attributes['tag']
    anchor = tag_anchor(tag)
  end

  title = "&lt;#{name}#{for_decl}&gt;"

  if link
    "[#{title}](##{anchor})"
  else
    title
  end
end


def link_to_tag(tag)
  tag_title(tag, true)
end


def tag_anchor(element)
  for_attr = element.attributes['for']
  name = element.attributes['tag']

  if for_attr
    "#{name}--for-#{for_attr}"
  else
    name
  end
end


def comment_for_tag(element)
  space = element.previous_sibling and
    space.to_s.blank? && space.to_s.count("\n") == 1 and
    comment = space.previous_sibling

  comment.to_s.strip if comment.is_a?(REXML::Comment)
end


def doc_for_tag(tagdef)
  comment = comment_for_tag(tagdef)

  params_merged_with = XPath.first(tagdef, ".//*[@merge|@merge-params]")._?.name
  params_merged_with &&= "(merged with #{link_to_tag params_merged_with})"

  attrs_merged_with = XPath.first(tagdef, ".//*[@merge|@merge-attrs]")._?.name
  attrs_merged_with &&= "(merged with #{link_to_tag attrs_merged_with})"

  attrs = tagdef.attributes['attrs'] || []
  attrs = attrs.split(/,\s*/).where_not.blank?.map { |a| " * #{a}\n" }.join

  parameters = params_to_list(get_parameters(tagdef))
<<-END
---

<a name="#{tag_anchor tagdef}">&nbsp;</a>
##  #{tag_title tagdef}

#{comment}

### Attributes #{attrs_merged_with}

#{attrs.blank? ? 'None' : attrs}

### Parameters #{params_merged_with}

#{parameters.blank? ? 'None' : parameters}
END
end


def get_parameters(elem)
  result = []
  elem.elements.each do |e|
    if e.attributes['param']
      result << [e, get_parameters(e)]
    else
      result.concat(get_parameters(e))
    end
  end
  result
end


def params_to_list(params, indent=" ")
  items = params.map do |elem, sub_params|
    p_attr = elem.attributes['param']
    entry = if p_attr == "&true"
              "&lt;#{elem.name}:&gt;"
            elsif p_attr =~ /#\{/
                "(dynamic parameter) (&lt;#{elem.name}&gt;)"
            else
              "&lt;#{p_attr}:&gt; (&lt;#{elem.name}&gt;)"
            end
    sub_list = params_to_list(sub_params, indent + ' ') unless sub_params.empty?
    "<li>#{entry}\n#{sub_list}</li>\n"
  end.join

  items.any? ? "<ul>#{items}</ul>" : ""
end


def contents(root)
  tags = XPath.match(root, '/*/*[@tag]')
  tags.map { |tag| " * #{link_to_tag tag}\n" }.join
end


def doc_for_taglib(title, root)
  tags = XPath.match(root, '/*/*[@tag]').map { |e| doc_for_tag(e) }.join("\n\n")

  "# #{title}\n\n" + contents(root) + "\n\n" + tags
end

def index_page(output_files, output_dir)
  markdown = "# Tag Documentation\n\n" + output_files.map do |f|
    link = f.gsub(output_dir+'/', '')
    link_text = link.gsub('_', '\_').gsub(/\.html$/, '')
    "* [#{link_text}](#{link})"
  end.join("\n")

  html = Maruku.new(markdown).to_html
  
  File.open("#{output_dir}/index.html", 'w') { |f| f.write(html) }
end

def process_directory(src, output_dir, output_format)
  raise RuntimeError, "#{output_dir} is not a directory" if File.exists?(output_dir) && !File.directory?(output_dir)

  FileUtils.mkdir output_dir unless File.exists? output_dir

  dryml_files = File.directory?(src) ? Dir["#{src}/*"] : [src]

  output_files = []

  dryml_files.each do |f|
    if File.directory?(f)
      output_files += process_directory(f, "#{output_dir}/#{File.basename(f)}", output_format)
    elsif f =~ /\.dryml$/
      basename = File.basename(f).sub(/\.dryml$/, '')
      title = basename.titleize

      doc = Hobo::Dryml::Parser::Document.new(File.read(f), f)

      output = doc.restore_erb_scriptlets(doc_for_taglib(title, doc))
      output = Maruku.new(output).to_html.gsub('&amp;', '&') if output_format == 'html'

      output_file = "#{output_dir}/#{basename}.#{output_format}"
      puts output_file
      File.open(output_file, 'w') { |f| f.write(output) }
      output_files << output_file
    end
  end
  output_files
end

  

namespace :hobo do

  desc "Generate markdown formatted reference docs automatically from DRYML taglibs"
  task :generate_tag_reference => :environment do
    gem 'maruku'
    require 'maruku'

    src = ENV['src']

    output_dir = ENV['output'] || "taglib-docs"
    
    output_format = ENV['format'] || "markdown"
    
    output_files = process_directory(src, output_dir, output_format)
    
    index_page(output_files, output_dir)
  end

end


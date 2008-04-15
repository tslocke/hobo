require 'fileutils'
require 'hobosupport'
Dependencies.load_paths << File.dirname(__FILE__) + "/../lib"

require 'rexml/xpath'
XPath = REXML::XPath

require 'maruku'

def link_to_tag(tag)
  if tag.in?($tags)
    "[`<#{tag}>`](##{tag})"
  else
    "`<#{tag}>`"
  end
end


def doc_for_tag(tagdef)
  name  = tagdef.attributes['tag']
  
  params_merged_with = XPath.first(tagdef, ".//*[@merge|@merge-params]")._?.name
  params_merged_with &&= "(merged with #{link_to_tag params_merged_with})"

  attrs_merged_with = XPath.first(tagdef, ".//*[@merge|@merge-attrs]")._?.name
  attrs_merged_with &&= "(merged with #{link_to_tag attrs_merged_with})"

  attrs = tagdef.attributes['attrs'] || []
  attrs = attrs.split(/,\s*/).where_not.blank?.map { |a| " * #{a}\n" }.join
  
  parameters = params_to_list(get_parameters(tagdef))
<<-END
## <a name="#{name}" />`<#{name}>`

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
              "#{elem.name}"
            elsif p_attr =~ /#\{/
                "(dynamic parameter) (#{elem.name})"
            else
              "#{p_attr} (#{elem.name})"
            end
    sub_list = params_to_list(sub_params, indent + ' ') unless sub_params.empty?
    "<li>#{entry}\n#{sub_list}</li>\n"
  end.join
  
  items.any? ? "<ul>#{items}</ul>" : ""
end


def contents(root)
  $tags.map { |tag| " * #{link_to_tag tag}\n" }.join
end


def doc_for_taglib(title, root)
  $tags = XPath.match(root, '/*/def').map {|e| e.attributes['tag'] }

  tags = XPath.match(root, '/*/def').map { |e| doc_for_tag(e) }.join("\n\n")  
  
  "# #{title}\n\n" + contents(root) + "\n\n" + tags
end

namespace :hobo do

  desc "Generate markdown formatted reference docs automatically from DRYML taglibs"
  task :generate_tag_reference do
    
    src = ENV['src']
    
    output_dir = ENV['output'] || "taglib-docs"
    raise RuntimeError, "#{output_dir} is not a directory" if File.exists?(output_dir) && !File.directory?(output_dir)
    
    FileUtils.mkdir output_dir unless File.exists? output_dir
    
    dryml_files = File.directory?(src) ? Dir["#{src}/*"] : [src]
    
    dryml_files.each do |f|
      basename = File.basename(f).sub(/\.dryml$/, '')
      title = basename.titleize

      doc = Hobo::Dryml::Parser::Document.new(File.read(f), f)
    
      markdown = doc_for_taglib(title, doc)
      html = Maruku.new(markdown).to_html
      
      output_file = "#{output_dir}/#{basename}.html"
      puts output_file
      File.open(output_file, 'w') { |f| f.write(html) }
    end
  end
  
end
  

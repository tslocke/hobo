require 'fileutils'

def restore_erb_scriptlets(scriptlets, src)
  src.gsub(/\[!\[HOBO-ERB(\d+)\s*\]!\]/m) {|s| "<%#{scriptlets[$1.to_i]}%>" }
end


def fix_nodes(nodes)
  nodes.map{|x| fix_element(x) if x.is_a?(REXML::Element) }
end


def start_tag_replace(el, repl)
  i, len = el.source_offset, el.start_tag_source.length
  @src[i..i+len-1] = repl
end
 
 
def classes?
  ENV['CLASS']
end

def ids?
  ENV['ID']
end


def string_interpolate_safe_dasherize(s)
  token = "[[MAKE_ME_A_DASH!]]"
  s.gsub("_", token).
    gsub(/\#\{.*?\}/) {|s2| s2.gsub(token, "_") }.
    gsub(token, "-")
end


def fix_children(element, template_params)
  element.elements.to_a.reverse.each do |e|
    # recurse first - we're going backwards
    is_template_call = e.dryml_name =~ /^[A-Z]/ && !e.attribute("replace")
    fix_children(e, is_template_call)
    
    fixed = fix_element(e, template_params)
    start_tag_replace(e, fixed)
  end
end


def fix_element(e, template_param)
  tag = e.start_tag_source.dup

  if e.dryml_name == "tagbody"
    tag.sub!("<tagbody", '<do param="default"')
  elsif e.dryml_name == "default_tagbody"
    tag.sub!("<default_tagbody", '<param-content')
  else
    tag.sub!("<#{e.dryml_name}", "<#{e.dryml_name.underscore.dasherize}#{':' if template_param}")
  end
  
  start = e.expanded_name.length+1
  tag[start..-1] = tag[start..-1].gsub(/([A-Za-z_]+)(\s*=\s*("(.*?)"|'(.*?)'))?/) do |s|
    _, name, _, value = *Regexp.last_match
    
    s.sub!(/^#{name}/, name.dasherize)
    
    if value 
      # underscore / dasherize the values of various attributes
      
      if e.name == "def" && name.in?(%w(tag attrs alias_of extend_with))
        s.sub!(/#{Regexp.escape(value)}$/) {|v| v.underscore.dasherize}
      
      elsif name.in?(%w(part update)) || (classes? && name == 'class') || (ids? && name == 'id')
        s.sub!(/#{Regexp.escape(value)}$/) {|v| string_interpolate_safe_dasherize(v) }

      elsif name == "param"
        s.sub!(/#{Regexp.escape(value)}$/) {|v| string_interpolate_safe_dasherize(v.underscore) }
      end
      
    end
    s
  end
  tag
end


def fix_file(filename)
  puts "Fixing #{filename}"
  src = File.read(filename)

  # Ripped from Hobo::Dryml::Template - hide erb scriptlets and parse with REXML
  scriptlets = {}
  src = src.gsub(/<%(.*?)%>/m) do
    _, scriptlet = *Regexp.last_match
    id = scriptlets.size + 1
    scriptlets[id] = scriptlet
    newlines = "\n" * scriptlet.count("\n")
    "[![HOBO-ERB#{id}#{newlines}]!]"
  end

  # DRYML doesn't have to have a single root - add one to keep REXML
  # happy
  @src = "<root>" + src + "</root>"
  begin
    doc = Hobo::Dryml::Parser::Document.new(Hobo::Dryml::Parser::Source.new(@src))
  rescue REXML::ParseException => e
    raise Exception, "File: #{@template_path}\n#{e}"
  end
  
  fix_children(doc[0], false)
  
  #Fix close tags
  @src.gsub!(/<\/[^:>]*/) { |s| s.underscore.dasherize }
  @src.gsub!(/<\/tagbody\s*>/, "</do>")
  
  # Strip the root tag we added
  @src.sub!(/^<root>/, "")
  @src.sub!(/<\/root>$/, "")
  
  fixed = restore_erb_scriptlets(scriptlets, @src)
  File.open(filename, 'w') { |f| f.write(fixed) }
end


namespace :hobo do

  desc "Replace old-style DRYML source code with CamelCaseTags and underscores with new DRYML syntax"
  task :fixdryml => :environment do
    
    dir = ENV['DIR']._?.sub(/\/$/, '') || "app/views"
    
    # Make a backup
    backup_dir = "#{dir.gsub('../', '').gsub('/', '_')}_before_fixdryml"
    if File.exist?(backup_dir)
      puts "Backup (#{backup_dir}) already exists - be careful! (nothing changed)"
      exit
    end
    FileUtils.cp_r(dir, backup_dir)
   
    Dir["#{dir}/**/*.dryml"].each do |f|
      fix_file(f)
    end
  end
  
end

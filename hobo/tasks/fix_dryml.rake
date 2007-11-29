require 'ruby-debug'
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
 
 
def fix_elements(element, template_params)
  element.elements.to_a.reverse.each do |e|
    # recurse first - we're going backwards
    fix_elements(e, e.name =~ /^[A-Z]/)
    
    start_tag_replace(e, fix_element(e, template_params))
  end
end

def classes?
  ENV['CLASS']
end

def ids?
  ENV['ID']
end


def fix_element(e, template_param)
  tag = e.start_tag_source.dup

  tag.sub!("<#{e.name}", "<#{e.name.dasherize}#{':' if template_param}")
  
  tag.sub!(/^<[A-Z][A-Za-z0-9_]*/) { |s| s.underscore.dasherize }
  
  tag.sub!("<tagbody", '<do param="default"') if e.name == "tagbody"
  tag.sub!("<default_tagbody", '<param-content') if e.name == "default_tagbody"
  
  
  tag.gsub!(/([A-Za-z_]+)(\s*=\s*("(.*?)"|'(.*?)'))?/) do |s|
    _, name, _, value = *Regexp.last_match
    
    s.sub!(/^#{name}/, name.dasherize)
    
    # dasherize the values of various attributes
    if value && (name.in?(%w(param part update)) ||
                 (classes? && name == 'class') ||
                 (ids? && name == 'id')
      s.sub!(/#{Regexp.escape(value)}$/) {|v| v.dasherize}
    end
    

    if e.name == "def" && name.in?(%w(tag attrs alias_of)) && value
      s.sub!(/#{Regexp.escape(value)}$/) {|v| v.underscore.dasherize}
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
    doc = REXML::Document.new(Hobo::Dryml::RexSource.new(@src), :dryml_mode => true)
  rescue REXML::ParseException => e
    raise Exception, "File: #{@template_path}\n#{e}"
  end
  
  fix_elements(doc[0], false)
  
  #Fix close tags
  @src.gsub!(/<\/.*?>/) do |s|
    s.underscore.dasherize
  end
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
    
    dir = ENV['DIR'] || "app/views"

    # Make a backup
    backup_dir = "#{dir.gsub '/', '_'}_before_fixdryml"
    if File.exist?(backup_dir)
      puts "Backup (#{backup_dir}) already exists - be careful!"
      exit
    end
    FileUtils.cp_r(dir, backup_dir)
   
    Dir["#{dir}/**/*.dryml"].each do |f|
      fix_file(f)
    end
    #fix_file("app/views/taglibs/application.dryml")
  end
  
end

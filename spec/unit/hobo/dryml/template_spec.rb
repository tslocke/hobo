require File.dirname(__FILE__) + '/../../../spec_helper'

Template = Hobo::Dryml::Template

describe Template do
  
  # --- Static Tags --- #
  
  it "should pass through tags declared as static" do
    "p".should be_in(Hobo.static_tags)
    eval_dryml("<p>abc</p>").should == "<p>abc</p>"
    eval_dryml("<p x='1'   y='2'>abc</p>").should == "<p x='1'   y='2'>abc</p>"
  end
  
  it "should pass through attributes with no rhs on static tags" do 
    "p".should be_in(Hobo.static_tags)
    eval_dryml("<p foo baa>abc</p>").should == "<p foo baa>abc</p>"    
  end

  
  # --- Defined Tags --- #
  
  it "should compile tag calls as method calls" do
    compile_dryml("<foo/>").should == "<%= foo() %>"
  end

  it "should compile tag attributes as keyword parameters" do
    compile_dryml("<foo a='1' b='2'/>").should == '<%= foo({:a => "1", :b => "2"}) %>'
  end
  
  it "should compile tag attributes with no RHS as passing `true`" do 
    compile_dryml("<foo a/>").should == '<%= foo({:a => true}) %>'
  end
  
  it "should compile the tag body as a block" do 
    compile_dryml("<foo>the body</foo>").should == "<% _output(foo() do %>the body<% end) %>"
  end
  
  it "should compile merged tags as calls to `merge_and_call`" do 
    compile_dryml("<foo merge/>").should == "<%= merge_and_call(:foo, {}, template_procs[:foo]) %>"
  end
  
  it "should compile merged tags with support for named merges" do 
    compile_dryml("<foo merge='zap'/>").should == "<%= merge_and_call(:foo, {}, template_procs[:zap]) %>"
  end

  
  # --- Template Tags --- # 
  
  it "should compile template calls as method calls" do 
    compile_dryml("<Foo/>").should == "<%= Foo() %>"
  end
  
  it "should compile template attributes as keyword parameters" do
    compile_dryml("<Foo a='1' b='2'/>").should == '<%= Foo({:a => "1", :b => "2"}) %>'
  end

  
  # --- Test Helpers --- #
  
  def prepare_template(src, template_path)
    Hobo::Dryml::Template.clear_build_cache
    @env = Class.new(Hobo::Dryml::TemplateEnvironment)
    Template.new(src, @env, template_path)
  end
  
  
  def eval_dryml(src, template_path="TEST", implicit_imports=false, this=nil, locals={})
    template = prepare_template(src, template_path)
    template.compile(locals.keys, implicit_imports)
    new_renderer.render_page(this, locals)
  end
  
  def compile_dryml(src, template_path="TEST"
                    )
    template = prepare_template(src, template_path)
    CompiledDryml.new(template.process_src)
  end

  def new_renderer
    @env.new("test-view", nil)
  end

end

class CompiledDryml < String
  
  def ==(other)
    self.to_s.gsub(/\s+/, ' ').strip == other.gsub(/\s+/, ' ').strip
  end
  
end

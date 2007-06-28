require File.dirname(__FILE__) + '/../../../spec_helper'

Template = Hobo::Dryml::Template
DrymlException = Hobo::Dryml::DrymlException

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

  
  # --- Calling Block Tags --- #
  
  it "should compile block-tag calls as method calls" do
    compile_dryml("<foo/>").should == "<%= foo() %>"
  end

  it "should compile attributes as keyword parameters" do
    compile_dryml("<foo a='1' b='2'/>").should == '<%= foo({:a => "1", :b => "2"}) %>'
  end
  
  it "should compile code attributes as ruby code" do 
    compile_dryml("<foo a='&1 + 2'/>").should == '<%= foo({:a => (1 + 2)}) %>'
  end
  
  it "should compile block-tag attributes with no RHS as passing `true`" do 
    compile_dryml("<foo a/>").should == '<%= foo({:a => true}) %>'
  end
  
  it "should compile content of a block-tag call as a Ruby block" do 
    compile_dryml("<foo>the body</foo>").should == "<% _output(foo() do %>the body<% end) %>"
  end
  
  # --- Defining Block Tags --- #
  
  it "should compile defs with lower-case names as block tags" do 
    compile_def("<def tag='foo'></def>").should == 
      "<% def foo(__options__={}, &__block__); " +
      "_tag_context(__options__, __block__) do |tagbody| options, = _tag_locals(__options__, []) %>" + 
      "<% _erbout; end; end %>"
  end
  
  # --- Defining Templates --- #
  
  it "should compile defs with cap names as templates" do 
    # Note the presence of the `template_procs` param, which block-tags don't have
    compile_def("<def tag='Foo'></def>").should == 
      "<% def Foo(__options__={}, template_procs, &__block__); " +
      "_tag_context(__options__, __block__) do |tagbody| options, = _tag_locals(__options__, []) %>" + 
      "<% _erbout; end; end %>"
  end
  
  it "should dissallow `merge` outside of template definitions" do 
    proc { compile_dryml("<foo merge/>") }.should raise_error(DrymlException)
  end
  
  it "should compile merged tag-calls as calls to `merge_and_call`" do 
    compile_in_template("<foo merge/>").should == "<%= merge_and_call(:foo, {}, template_procs[:foo]) %>"
  end
  
  it "should compile merged tag-calls with support for named merges" do 
    compile_in_template("<foo merge='zap'/>").should == "<%= merge_and_call(:foo, {}, template_procs[:zap]) %>"
  end

  it "should compile a merged tag-call with body" do 
    compile_in_template("<foo merge>abc</foo>").should == 
      "<% _output(merge_and_call(:foo, {}, template_procs[:foo]) do %>abc<% end) %>"
  end
  
  it "should compile merged template-calls as calls to `merge_and_call_template`" do 
    compile_in_template("<Foo merge/>").should == 
      "<% _output(merge_and_call_template(:Foo, {}, {}, template_procs[:Foo])) %>"
  end
  
  it "should compile template parameters with merge" do
    compile_in_template("<Foo><abc merge/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_template_parameter(proc { {} }, template_procs[:abc])})) %>'
  end
  
  it "should compile template parameters with named merges" do
    compile_in_template("<Foo><abc merge='x'/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_template_parameter(proc { {} }, template_procs[:x])})) %>'
  end
  
  it "should compile template parameters with merge and attributes" do
    compile_in_template("<Foo><abc merge='x' a='b'/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_template_parameter(proc { {:a => "b"} }, template_procs[:x])})) %>'
  end
  
  it "should compile template parameters with merge and a tag body" do
    compile_in_template("<Foo><abc merge>ha!</abc></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_template_parameter(proc { {:content => %>ha!<% } }, template_procs[:abc])})) %>'
  end

  # --- Calling Templates --- # 
  
  it "should compile template calls as method calls" do 
    compile_dryml("<Foo/>").should == "<% _output(Foo({}, {})) %>"
  end
  
  it "should compile attributes on template calls as keyword parameters" do
    compile_dryml("<Foo a='1' b='2'/>").should == '<% _output(Foo({:a => "1", :b => "2"}, {})) %>'
  end
  
  it "should compile template parameters as procs" do 
    compile_dryml("<Foo><x>hello</x><y>world</y></Foo>").should ==
      '<% _output(Foo({}, {:x => proc { {:content => %>hello<% } }, :y => proc { {:content => %>world<% } }})) %>'
  end
  
  it "should compile template parameters with attributes" do
    compile_dryml("<Foo><abc x='1'>hello</abc></Foo>").should ==
      '<% _output(Foo({}, {:abc => proc { {:x => "1", :content => %>hello<% } }})) %>'
  end
  


  
  # --- Test Helpers --- #
  
  def prepare_template(src, options)
    options.reverse_merge!(:template_path => "TEST")
    
    Hobo::Dryml::Template.clear_build_cache
    @env = Class.new(Hobo::Dryml::TemplateEnvironment)
    template = Template.new(src, @env, options[:template_path])

    template.instance_variable_set("@builder", options[:builder]) if options[:builder]
    template
  end
  
  
  def eval_dryml(src, options={})
    options.reverse_merge!(:locals => {})
    
    template = prepare_template(src, options)
    template.compile(options[:locals].keys, options[:implicit_imports])
    new_renderer.render_page(options[:this], options[:locals])
  end
  
  def compile_dryml(src, options={})
    template = prepare_template(src, options)
    CompiledDryml.new(template.process_src)
  end

  def new_renderer
    @env.new("test-view", nil)
  end

  def compile_in_template(src)
    builder = mock("builder", :null_object => true)
    def_src = nil
    builder.should_receive(:add_build_instruction) do |type, args| 
      def_src = args[:src]
    end
    compile_dryml("<def tag='MyTemplate'>#{src}</def>", :builder => builder)
    
    # get rid of first and last scriptlets - they're to do with the method declaration
    def_src.to_s.sub(/^\<\%.*?\%\>/, "").sub(/<% _erbout; end; end %>$/, "")
  end
  
  def compile_def(src)
    builder = mock("builder", :null_object => true)
    def_src = nil
    builder.should_receive(:add_build_instruction) do |type, args| 
      def_src = args[:src]
    end
    compile_dryml(src, :builder => builder)
    
    def_src
  end
  
end

class CompiledDryml < String
  
  def ==(other)
    self.to_s.gsub(/\s+/, ' ').strip == other.gsub(/\s+/, ' ').strip
  end
  
end

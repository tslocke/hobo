require File.dirname(__FILE__) + '/../../../spec_helper'

Template = Hobo::Dryml::Template
DrymlException = Hobo::Dryml::DrymlException

describe Template do
  
  # --- Tag Compilation Examples --- #

  # --- Compilation: Calling Block Tags --- #
  
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
    compile_dryml("<foo a/>").should == '<%= foo({:a => (true)}) %>'
  end
  
  it "should compile content of a block-tag call as a Ruby block" do 
    compile_dryml("<foo>the body</foo>").should == "<% _output(foo() do %>the body<% end) %>"
  end
  
    
  it "should allow :foo as a shorthand for field='foo' on block tags" do 
    compile_dryml("<foo:name/>").should == '<%= foo({:field => "name"}) %>'
  end
  
  it "should allow close tags to ommit the :field_name part" do 
    compile_dryml("<foo:name></foo>").should == '<%= foo({:field => "name"}) %>'
  end

  # --- Compilation: Defining Block Tags --- #
  
  it "should compile defs with lower-case names as block tags" do 
    compile_def("<def tag='foo'></def>").should == 
      "<% def foo(__options__={}, &__block__); " +
      "_tag_context(__options__, __block__) do |tagbody| options, = _tag_locals(__options__, []) %>" + 
      "<% _erbout; end; end %>"
  end
  
  it "should compile attrs in defs as local variables" do 
    compile_def("<def tag='foo' attrs='a, b'></def>").should == 
      "<% def foo(__options__={}, &__block__); " +
      "_tag_context(__options__, __block__) do |tagbody| a, b, options, = _tag_locals(__options__, [:a, :b]) %>" + 
      "<% _erbout; end; end %>"
  end
  
  # --- Compilation: Defining Templates --- #
  
  it "should compile defs with cap names as templates" do 
    # Note the presence of the `template_procs` param, which block-tags don't have
    compile_def("<def tag='Foo'></def>").should == 
      "<% def Foo(__options__={}, template_procs={}, &__block__); " +
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
      '<% _output(Foo({}, {:abc => merge_template_parameter(proc { {:tagbody => proc { new_context { %>ha!<% } } } }, template_procs[:abc])})) %>'
  end

  # --- Compilation: Calling Templates --- # 
  
  it "should compile template calls as method calls" do 
    compile_dryml("<Foo/>").should == "<% _output(Foo({}, {})) %>"
  end
  
  it "should compile attributes on template calls as keyword parameters" do
    compile_dryml("<Foo a='1' b='2'/>").should == '<% _output(Foo({:a => "1", :b => "2"}, {})) %>'
  end
  
  it "should compile template parameters as procs" do 
    compile_dryml("<Foo><x>hello</x><y>world</y></Foo>").should ==
      '<% _output(Foo({}, {' + 
      ':x => proc { {:tagbody => proc { new_context { %>hello<% } } } }, ' + 
      ':y => proc { {:tagbody => proc { new_context { %>world<% } } } }})) %>'
  end
  
  it "should compile template parameters with attributes" do
    compile_dryml("<Foo><abc x='1'>hello</abc></Foo>").should ==
      '<% _output(Foo({}, {:abc => proc { {:x => "1", :tagbody => proc { new_context { %>hello<% } } } }})) %>'
  end
  
  it "should allow :foo as a shorthand for field='foo' on template tags" do 
    compile_dryml("<Foo:name/>").should == '<%= Foo({:field => "name"}) %>'
  end


  
  # --- Tag Evalutation Examples --- #
  
  
  
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
  
  
  # --- Block Tags --- #
  
  
  def eval_with_defs(dryml)
    eval_dryml(<<-END + dryml).strip
      <def tag="t">plain tag</def>

      <def tag="t_attr" attrs="x">it is <%= x %></def>

      <def tag="t_body">( <tagbody/> )</def>

      <def tag="merge_attrs_example"><p merge_attrs>hi</p></def>
    END
  end

  it "should call block tags" do 
    eval_with_defs("<t/>").should == "plain tag"
  end
    

  it "should call block tags passing attributes" do
    eval_with_defs("<t_attr x='10'/>").should == "it is 10"
  end
  
  it "should call block tags with a body" do
    eval_with_defs("<t_body>foo</t_body>").should == "( foo )"
  end
  
    
  it "should support merge_attrs on static tags" do 
    eval_with_defs('<merge_attrs_example class="x"/>').should == '<p class="x">hi</p>'
  end

  
  
  # --- Template Tags --- #
  
  def eval_with_templates(dryml)
    eval_dryml(<<-END + dryml).strip
      <def tag="defined" attrs="a, b">a is <%= a %>, b is <%= b %>, body is <tagbody/></def>

      <def tag="T">plain template</def>

      <def tag="StaticMerge"><p>a <b class="big" merge>bold</b> word</p></def>

      <def tag="DefTagMerge">foo <defined merge b="3">baa</defined>!</def>
    END
  end

  it "should call template tags" do
    eval_with_templates("<T/>").should == "plain template"
  end

  
  it "should add attributes to static tags when merging" do 
    eval_with_templates("<StaticMerge><b onclick='alert()'/></StaticMerge>").should == 
      '<p>a <b class="big" onclick="alert()">bold</b> word</p>'    
  end
  

  it "should override attributes on static tags when merging" do 
    eval_with_templates("<StaticMerge><b class='small'/></StaticMerge>").should == 
      '<p>a <b class="small">bold</b> word</p>'
  end
  
  
  it "should replace tag bodies on static tags when merging" do
    eval_with_templates('<StaticMerge><b>BOLD</b></StaticMerge>').should == 
      '<p>a <b class="big">BOLD</b> word</p>'
  end
  
  it "should add attributes to defined tags when merging" do 
    eval_with_templates('<DefTagMerge><defined a="2"/></DefTagMerge>').should ==
      'foo a is 2, b is 3, body is baa!'
  end
  
  it "should override attributes on defined tags when merging" do 
    eval_with_templates('<DefTagMerge><defined b="2"/></DefTagMerge>').should ==
      'foo a is , b is 2, body is baa!'
  end
  
  it "should replace tag bodies on defined tags when merging" do 
    eval_with_templates('<DefTagMerge><defined>zip</defined></DefTagMerge>').should ==
      'foo a is , b is 3, body is zip!'
  end
  
  it "should leave non-merged tags unchanged" do
    eval_with_templates('<StaticMerge></StaticMerge>').should ==
      '<p>a <b class="big">bold</b> word</p>'
  end
  
  it "should merge template parameters into nested templates"
    
  
  
  
  
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

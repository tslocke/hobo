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
  
  it "should allow :title as a shorthand for field='title' on block tags (title is a static tag)" do 
    compile_dryml("<foo:name/>").should == '<%= foo({:field => "name"}) %>'
  end
  
  it "should allow close tags to ommit the :field_name part" do 
    compile_dryml("<foo:name></foo>").should == '<%= foo({:field => "name"}) %>'
  end

  it "should compile block-tag calls with merge_attrs" do
    compile_dryml("<foo merge_attrs/>").should == "<%= foo({}.merge((attributes) || {})) %>"
    compile_dryml("<foo a='1' merge_attrs/>").should == '<%= foo({:a => "1"}.merge((attributes) || {})) %>'
  end

  # --- Compilation: Defining Block Tags --- #
  
  it "should compile defs with lower-case names as block tags" do 
    compile_def("<def tag='foo'></def>").should == 
      "<% def foo(__attributes__={}, &__block__); " +
      "parameters = nil; " +
      "_tag_context(__attributes__, __block__) do |tagbody| attributes, = _tag_locals(__attributes__, []) %>" + 
      "<% _erbout; end; end %>"
  end
  
  it "should compile attrs in defs as local variables" do 
    compile_def("<def tag='foo' attrs='a, b'></def>").should == 
      "<% def foo(__attributes__={}, &__block__); " +
      "parameters = nil; " +
      "_tag_context(__attributes__, __block__) do |tagbody| " +
      "a, b, attributes, = _tag_locals(__attributes__, [:a, :b]) %>" + 
      "<% _erbout; end; end %>"
  end
  
  # --- Compilation: Defining Templates --- #
  
  it "should compile defs with cap names as templates" do 
    # Note the presence of the `parameters` param, which block-tags don't have
    compile_def("<def tag='Foo'></def>").should == 
      "<% def Foo(__attributes__={}, all_parameters={}, &__block__); " +
      "parameters = all_parameters - []; " +
      "_tag_context(__attributes__, __block__) do |tagbody| attributes, = _tag_locals(__attributes__, []) %>" + 
      "<% _erbout; end; end %>"
  end
  
  it "should dissallow `param` outside of template definitions" do 
    proc { compile_dryml("<foo param/>") }.should raise_error(DrymlException)
  end
  
  it "should compile merged tag-calls as calls to `merge_and_call`" do 
    compile_in_template("<foo param a='1'/>").should == '<%= merge_and_call(:foo, {:a => "1"}, all_parameters[:foo]) %>'
  end
  
  it "should compile merged tag-calls with support for named params" do 
    compile_in_template("<foo param='zap'/>").should == "<%= merge_and_call(:foo, {}, all_parameters[:zap]) %>"
  end

  it "should compile a merged tag-call with body" do 
    compile_in_template("<foo param>abc</foo>").should == 
      "<% _output(merge_and_call(:foo, {}, all_parameters[:foo]) do %>abc<% end) %>"
  end
  
  it "should compile merged template-calls as calls to `merge_and_call_template`" do 
    compile_in_template("<Foo param/>").should == 
      "<% _output(merge_and_call_template(:Foo, {}, {}, all_parameters[:Foo])) %>"
  end
  
  it "should compile merged template-calls with parameters as calls to `merge_and_call_template`" do 
    compile_in_template("<Foo param><a x='1'/></Foo>").should == 
      '<% _output(merge_and_call_template(:Foo, {}, {:a => proc { {:x => "1"} }}, all_parameters[:Foo])) %>'
  end
  
  it "should compile template parameters with param" do
    compile_in_template("<Foo><abc param/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_option_procs(proc { {} }, all_parameters[:abc])})) %>'
  end
  
  it "should compile template parameters with named params" do
    compile_in_template("<Foo><abc param='x'/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_option_procs(proc { {} }, all_parameters[:x])})) %>'
  end
  
  it "should compile template parameters with param and attributes" do
    compile_in_template("<Foo><abc param='x' a='b'/></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_option_procs(proc { {:a => "b"} }, all_parameters[:x])})) %>'
  end
  
  it "should compile template parameters with param and a tag body" do
    compile_in_template("<Foo><abc param>ha!</abc></Foo>").should == 
      '<% _output(Foo({}, {:abc => merge_option_procs(' +
      'proc { {:tagbody => proc { new_context { %>ha!<% } } } }, all_parameters[:abc])})) %>'
  end
  
  it "should compile template parameters which are template calls themselves" do 
    compile_in_template("<Foo><Baa param x='1'/></Foo>").should == 
      '<% _output(Foo({}, {:Baa => merge_template_parameter_procs(proc { [{:x => "1"}, {}] }, all_parameters[:Baa])})) %>'
  end

  it "should compile template parameters which are templates themselves with their own parameters" do 
    compile_in_template("<Foo><Baa param><x>hello</x></Baa></Foo>").should == 
      '<% _output(Foo({}, {:Baa => merge_template_parameter_procs(' + 
      'proc { [{}, {:x => proc { {:tagbody => proc { new_context { %>hello<% } } } }}] }, all_parameters[:Baa])})) %>'
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
    compile_dryml("<Foo:name/>").should == '<% _output(Foo({:field => "name"}, {})) %>'
  end
  
  it "should dissallow tag-bodies on template calls" do 
    proc { compile_dryml("<Foo>this is a tag body</Foo>") }.should raise_error(DrymlException)
  end
  
  it "should dissallow tag-bodies on nested template calls" do 
    proc { compile_dryml("<Foo><Baa>this is a tag body</Baa></Foo>") }.should raise_error(DrymlException)
  end
  
  it "should compile template parameters which are themselves templates" do 
    # Template parameters which are themselves templates are procs
    # that return a pair of hashes, the first is the attributes to the
    # template, the second is the sub-template procs
    compile_dryml("<Foo><Baa x='1'><a>hello</a></Baa></Foo>").should ==
      '<% _output(Foo({}, ' +
      '{:Baa => proc { [{:x => "1"}, {:a => proc { {:tagbody => proc { new_context { %>hello<% } } } }}] }})) %>'
  end

  it "should compile template modifier parameters " do
    compile_dryml("<Page><head.append>abc</head.append></Page>").should == 
      '<% _output(Page({}, {:head => proc { {:_append => proc { new_context { %>abc<% } }} }})) %>'
  end
  
  it "should compile consecutive template modifier parameters " do
    compile_dryml("<Page><head.append>abc</head.append><head.prepend>def</head.prepend></Page>").should == 
      '<% _output(Page({}, {:head => proc { {:_append => proc { new_context { %>abc<% } }, ' + 
      ':_prepend => proc { new_context { %>def<% } }} }})) %>'
  end
  
  it "should compile modifiers and a parameter on the same template parameter" do 
    compile_dryml("<Page><head.before>abc</head.before><head x='1'/></Page>").should == 
      '<% _output(Page({}, {:head => proc { {:_before => proc { new_context { %>abc<% } }, :x => "1"} }})) %>'
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
  
  it "should support attribute merging on static tags" do 
    eval_dryml(%(<p class="big" id="x" merge_attrs="&{:class => 'small', :id => 'y', :a => 'b'}"/>)).
      should be_dom_equal_to('<p class="big small" id="y" a="b"/>')
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
  
  it "should make the declared attributes available via the 'attrs_for' method" do 
    eval_with_defs('<%= attrs_for(:t_attr).inspect %>').should == '[:x]'
  end

  
  
  # --- Template Tags --- #
  
  def eval_with_templates(dryml)
    eval_dryml(<<-END + dryml).strip
      <def tag="defined" attrs="a, b">a is <%= a %>, b is <%= b %>, body is <tagbody/></def>

      <def tag="T">plain template</def>

      <def tag="StaticMerge"><p>a <b class="big" param>bold</b> word</p></def>

      <def tag="EmptyStaticMerge"><img class="big" src="..." param/></def>

      <def tag="DefTagMerge">foo <defined param b="3">baa</defined>!</def>

      <def tag="NestedStaticMerge">merge StaticMerge: <StaticMerge param/></def>

      <def tag="ParameterMerge">parameter merge: <StaticMerge><b param/></StaticMerge></def>
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
  
  it "should merge into static tags with no body" do
    eval_with_templates("<EmptyStaticMerge><img class='small'/></EmptyStaticMerge>").should == 
      '<img class="small" src="..." />'
  end
    
  it "should merge template parameters into nested templates" do 
    eval_with_templates('<NestedStaticMerge><StaticMerge><b class="small"/></StaticMerge></NestedStaticMerge>').should ==
      'merge StaticMerge: <p>a <b class="small">bold</b> word</p>'
  end
  
  it "should merge the body of template parameters into nested templates" do 
    eval_with_templates('<NestedStaticMerge><StaticMerge><b>BOLD</b></StaticMerge></NestedStaticMerge>').should ==
      'merge StaticMerge: <p>a <b class="big">BOLD</b> word</p>'
  end
  
  it "should allow param names to be defined dynamically" do 
    eval_dryml('<def tag="T"><p param="& :a.to_s + :b.to_s"/></def>' +
               '<T><ab x="1"/></T>').should == '<p x="1" />'
  end
  
  it "should allow params to be defined on other params" do 
    eval_with_templates('<ParameterMerge><b class="small">foo</b></ParameterMerge>').should == 
      'parameter merge: <p>a <b class="small">foo</b> word</p>'
    
  end
  
  
  
  # --- Template Parameter Modifiers --- #
  
  it "should allow content to be inserted before template parameters" do 
    eval_with_templates("<StaticMerge><b.before>!!!</b.before></StaticMerge>").should == 
      '<p>a !!!<b class="big">bold</b> word</p>'
  end
  
  it "should allow content to be inserted after template parameters" do 
    eval_with_templates("<StaticMerge><b.after>!!!</b.after></StaticMerge>").should == 
      '<p>a <b class="big">bold</b>!!! word</p>'
  end
  
  it "should allow content to be prepended to template parameter bodies" do 
    eval_with_templates("<StaticMerge><b.prepend>!!!</b.prepend></StaticMerge>").should == 
      '<p>a <b class="big">!!!bold</b> word</p>'
  end
  
  it "should allow content to be prepended to template parameter bodies" do 
    eval_with_templates("<StaticMerge><b.append>!!!</b.append></StaticMerge>").should == 
      '<p>a <b class="big">bold!!!</b> word</p>'
  end

  it "should allow template parameters to be replaced entirely" do 
    eval_with_templates("<StaticMerge><b.replace>!!!</b.replace></StaticMerge>").should == 
      '<p>a !!! word</p>'
  end
  
  it "should allow content to be inserted before template parameters that are templates" do 
    eval_with_templates("<NestedStaticMerge><StaticMerge.before>!!!</StaticMerge.before></NestedStaticMerge>").should ==
      'merge StaticMerge: !!!<p>a <b class="big">bold</b> word</p>'
  end

  it "should allow content to be inserted after template parameters that are templates" do 
    eval_with_templates("<NestedStaticMerge><StaticMerge.after>!!!</StaticMerge.after></NestedStaticMerge>").should ==
      'merge StaticMerge: <p>a <b class="big">bold</b> word</p>!!!'
  end

  it "should allow template parameters that are templates to be replaced entirely" do 
    eval_with_templates("<NestedStaticMerge><StaticMerge.replace>!!!</StaticMerge.replace></NestedStaticMerge>").
      should == 'merge StaticMerge: !!!'
    eval_with_templates("<NestedStaticMerge><StaticMerge.replace/></NestedStaticMerge>").
      should == 'merge StaticMerge:'
  end

  
  # --- Merge Params --- #
  
  
  it "should support merge_param on template calls" do
    tags = %(<def tag="Page"><h1 param='title'/><div param='footer'/></def>
             <def tag="MyPage"><Page merge_params><footer>the footer</footer></Page></def>)

    eval_dryml(tags + "<MyPage><title>Hi!</title></MyPage>").should == '<h1>Hi!</h1><div>the footer</div>'
  end
  
  
  # --- The Context --- #
  
  def context_eval(context, src)
    eval_dryml(src, :context => context)
  end
  
  def a_user
    Struct.new(:name, :email).new("Tom", "tom@foo.net")
  end
  
  def show_tag
    '<def tag="show"><%= this %></def>'
  end
  
  it "should make the initial context available as `this`"  do 
    context_eval('hello', "<%= this %>").should == "hello"
  end
  
  it "should allow the context to be changed with the :<field-name> syntax" do 
    context_eval(a_user, show_tag + '<show:name/>').should == "Tom"
  end
  
  it "should allow the :<field-name> to be ommitted from the close tag" do 
    context_eval(a_user, show_tag + '<show:name></show:name>').should == "Tom"
    context_eval(a_user, show_tag + '<show:name></show>').should == "Tom"
  end
  
  
  it "should allow the context to be changed with a 'with' attribute" do 
    eval_dryml(show_tag + %(<show with="&'hello'"/>)).should == 'hello'
  end
  
  it "should allow the context to be changed with a 'field' attribute" do 
    context_eval(a_user, show_tag + '<show field="name"/>').should == "Tom"
  end
  
  it "should allow the context to be changed inside template parameters" do 
    tags = %(<def tag="do"><tagbody/></def>
             <def tag="Template"><do:name><p param/></do></def>)
    context_eval(a_user, tags + '<Template><p><%= this %></p></Template>').should == '<p>Tom</p>'
  end

  
  # --- Local Tags --- #
  
  
  it "should allow tags to be overriden with local tags" do 
    eval_dryml("<def tag='foo'>ab</def>\n" +
               "<def tag='test'><def tag='foo'>cd</def> <foo/> </def>\n" +
               "<test/>").should == "cd"
  end
  
  it "should allow local tags to be new tags" do
    eval_dryml("<def tag='test'><def tag='foo'>cd</def> <foo/> </def>\n" +
               "<test/>").should == "cd"
  end
  
  it "should make local tags available in the tagobdy of the local tags parent" do 
    eval_dryml("<def tag='test'><def tag='foo'>cd</def> <tagbody/> </def>\n" +
               "<test><foo/></test>").should == "cd"
  end
  
  it "should allow local tags to capture local state" do
    eval_dryml("<def tag='test' attrs='x'><def tag='foo'><%= x %></def> <tagbody/> </def>\n" +
               "<test x='abc'><foo/></test>").should == "abc"
  end
  
  it "should allow local tags to modify captured state" do
    eval_dryml("<def tag='test'><set x='&0'/><def tag='foo'><% x += 1 %></def> <tagbody/> <%= x %></def>\n" +
               "<test x='abc'><foo/><foo/><foo/></test>").should == "3"
  end    
  
  
  # --- Misc --- #
  
  it "should provide <set> to create local variables" do
    eval_dryml("<set x='&1' y='&2'/><%= x + y %>").should == '3'
  end
  
  it 'should interpolate #{...} blocks in attributes of any tag' do 
    tag = '<def tag="t" attrs="x"><%= x %></def>'
    
    eval_dryml(tag + "<t x='#{1+2}'/>").should == '3'
    eval_dryml(tag + "<t x='hey #{1+2} ho'/>").should == 'hey 3 ho'

    eval_dryml(tag + "<p class='#{1+2}'/>").should == "<p class='3'/>"
    eval_dryml(tag + "<p class='hey #{1+2} ho'/>").should == "<p class='hey 3 ho'/>"
  end
  
  
  # --- Taglibs --- #
  
  it "should import tags from taglibs with the <include> tag" do 
    eval_dryml("<include src='taglibs/simple'/> <foo/>").should == "I am the foo tag"
  end
  
  it "should import tags from taglibs into a namespace with <include as/>" do 
    proc { eval_dryml("<include src='taglibs/simple' as='a'/> <foo/>") }.should raise_error
    eval_dryml("<include src='taglibs/simple' as='a'/> <a.foo/>").should == "I am the foo tag"
  end
  
  
  # --- Control Attributes --- #
  
  it "should alow tags to be conditional with the 'if' attribute" do 
    eval_dryml("<p if='&false'/>").should == ""
    eval_dryml("<p if='&true'/>").should == "<p />"

    eval_dryml("<p if='&false'>hello</p>").should == ""
    eval_dryml("<p if='&true'>hello</p>").should == "<p>hello</p>"
  end
  
  it "should alow tags to be repeated with the 'repeat' attribute" do 
    eval_dryml('<img repeat="&[1,2,3]" src="#{this}" />').should == 
      '<img src="1" /><img src="2" /><img src="3" />'
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
    options.reverse_merge!(:locals => {}, :implicit_imports => [])
    
    template = prepare_template(src, options)
    template.compile(options[:locals].keys, options[:implicit_imports])
    new_renderer.render_page(options[:context], options[:locals]).strip
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
    def_src.to_s.sub(/^\<\%.*?\%\>/, "").sub(/<% _erbout; end; end %><% _register_tag_attrs.*$/, "")
  end
  
  def compile_def(src)
    builder = mock("builder", :null_object => true)
    def_src = nil
    builder.should_receive(:add_build_instruction) do |type, args| 
      def_src = args[:src]
    end
    compile_dryml(src, :builder => builder)
    
    def_src.sub(/<% _register_tag_attrs.*/, "")
  end
  
end

class CompiledDryml < String
  
  def ==(other)
    self.to_s.gsub(/\s+/, ' ').strip == other.gsub(/\s+/, ' ').strip
  end
  
end


module Spec
  module Matchers

    class BeDomEqualTo #:nodoc:
      def initialize(expected)
        @expected = expected
      end
      
      def matches?(actual)
        @actual = actual
        expected_dom = HTML::Document.new(@expected).root
        actual_dom = HTML::Document.new(@actual).root
        expected_dom == actual_dom
      end
      
      def failure_message
        "#{@expected}\nexpected to be == (by DOM) to\n#{@actual}"
      end
      
      def description
        "be DOM equal to\n#{@expected}"
      end
    end
    
    def be_dom_equal_to(expected)
      Matchers::BeDomEqualTo.new(expected)
    end
  end
end

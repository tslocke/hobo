require File.dirname(__FILE__) + '/../../../spec_helper'

Template = Hobo::Dryml::Template
DrymlException = Hobo::Dryml::DrymlException

describe Template do

  # --- Tag Compilation Examples --- #

  # --- Compilation: Calling Tags --- #

  it "should compile tag calls as method calls" do
    compile_dryml("<foo/>").should == "<% _output(foo.to_s) %>"
  end

  it "should convert dashes in tag names to underscores in compiled method calls" do
    compile_dryml("<foo-baa/>").should == "<% _output(foo_baa.to_s) %>"
  end

  it "should compile attributes as keyword parameters" do
    compile_dryml("<foo a='1' b='2'/>").should == '<% _output(foo({:a => "1", :b => "2"}, {})) %>'
  end

  it "should convert attribute names with dashes in tag calls to symbols with underscores" do
    compile_dryml("<foo my-attribute='1'/>").should == "<% _output(foo({:my_attribute => \"1\"}, {})) %>"
  end

  it "should compile code attributes as ruby code" do
    compile_dryml("<foo a='&1 + 2'/>").should == '<% _output(foo({:a => (1 + 2)}, {})) %>'
  end

  it "should compile attributes with no RHS as passing `true`" do
    compile_dryml("<foo a/>").should == '<% _output(foo({:a => (true)}, {})) %>'
  end

  it "should compile content of a tag call as the default parameter" do
    compile_dryml("<foo>the body</foo>").should == "<% _output(foo({}, { :default => proc { |_foo__default_content| new_context { %>the body<% } }, })) %>"
  end

  it "should support <param_content/> inside the content of a tag" do
    compile_dryml("<foo>!!<param-content/>??</foo>").should ==
      "<% _output(foo({}, { :default => proc { |_foo__default_content| new_context { %>!!<%= _foo__default_content && _foo__default_content.call %>??<% } }, })) %>"
  end

  it "should support the 'for' attribute on <param-content/>" do
    compile_dryml("<x><y>123<param-content for='x'/>456</y></x>").should ==
      "<% _output(x({}, { :default => proc { |_x__default_content| new_context { %><% _output(y({}, { :default => proc { |_y__default_content| new_context { %>" +
      "123<%= _x__default_content && _x__default_content.call %>456" +
      "<% } }, })) %><% } }, })) %>"
  end

  it "should allow :foo as a shorthand for field='foo' on tags" do
    compile_dryml("<foo:name/>").should == '<% _output(foo({:field => "name"}, {})) %>'
  end

  it "should allow static tag names like :title as a shorthand for field='title'" do
    compile_dryml("<foo:name/>").should == '<% _output(foo({:field => "name"}, {})) %>'
  end

  it "should allow close tags to ommit the :field_name part" do
    compile_dryml("<foo:name></foo>").should ==
      '<% _output(foo({:field => "name"}, { :default => proc { |_foo__default_content| new_context { %><% } }, })) %>'
  end

  it "should compile tag calls with merge-attrs" do
    compile_dryml("<foo merge-attrs/>").should == "<% _output(foo(merge_attrs({},(attributes) || {}), {})) %>"
    compile_dryml("<foo a='1' merge-attrs/>").should == '<% _output(foo(merge_attrs({:a => "1"},(attributes) || {}), {})) %>'
  end


  # --- Compilation: Defining Tags --- #

  it "should compile defs" do
    compile_def("<def tag='foo'></def>").should ==
      "<% def foo(all_attributes={}, all_parameters={}); " +
      "parameters = Hobo::Dryml::TagParameters.new(all_parameters, []); " +
      "all_parameters = Hobo::Dryml::TagParameters.new(all_parameters); " +
      "_tag_context(all_attributes) do attributes, = _tag_locals(all_attributes, []) %>" +
      "<% _erbout; end; end %>"
  end

  it "should compile attrs in defs as local variables" do
    compile_def("<def tag='foo' attrs='a, my-attr'></def>").should ==
      "<% def foo(all_attributes={}, all_parameters={}); " +
      "parameters = Hobo::Dryml::TagParameters.new(all_parameters, []); " +
      "all_parameters = Hobo::Dryml::TagParameters.new(all_parameters); " +
      "_tag_context(all_attributes) do " +
      "a, my_attr, attributes, = _tag_locals(all_attributes, [:a, :my_attr]) %>" +
      "<% _erbout; end; end %>"
  end

  it "should dissallow `param` outside of tag definitions" do
    proc { compile_dryml("<foo param/>") }.should raise_error(DrymlException)
  end

  it "should compile param-tag calls as calls to `call_tag_parameter`" do
    compile_in_template("<foo param a='1'/>").should == '<% _output(call_tag_parameter(:foo, {:a => "1"}, {}, all_parameters, :foo)) %>'
  end

  it "should compile with support for named params" do
    compile_in_template("<foo param='zap'/>").should == "<% _output(call_tag_parameter(:foo, {}, {}, all_parameters, :zap)) %>"
  end

  it "should compile a param tag-call with a body" do
    compile_in_template("<foo param>abc</foo>").should ==
      "<% _output(call_tag_parameter(:foo, {}, { :default => proc { |_foo__default_content| new_context { %>abc<% } }, }, all_parameters, :foo)) %>"
  end

  it "should compile a param tag-call with a body and a call to <param_content/>" do
    compile_in_template("<foo param>!!<param-content/>!!</foo>").should ==
      "<% _output(call_tag_parameter(:foo, {}, { :default => proc { |_foo__default_content| new_context { %>!!<%= _foo__default_content && _foo__default_content.call %>!!<% } }, }, all_parameters, :foo)) %>"
  end

  it "should compile param template-calls as calls to `call_tag_parameter`" do
    compile_in_template("<foo param/>").should ==
      "<% _output(call_tag_parameter(:foo, {}, {}, all_parameters, :foo)) %>"
  end

  it "should compile param tag calls with parameters as calls to `call_tag_parameter`" do
    compile_in_template("<foo param><a: x='1'/></foo>").should ==
      '<% _output(call_tag_parameter(:foo, {}, {:a => proc { [{:x => "1"}, {}] }, }, all_parameters, :foo)) %>'
  end

  it "should compile parameters with param" do
    compile_in_template("<foo><abc: param/></foo>").should ==
      '<% _output(foo({}, {:abc => merge_tag_parameter(proc { [{}, {}] }, all_parameters[:abc]), })) %>'
  end

  it "should compile tag parameters with named params" do
    compile_in_template("<foo><abc: param='x'/></foo>").should ==
      '<% _output(foo({}, {:abc => merge_tag_parameter(proc { [{}, {}] }, all_parameters[:x]), })) %>'
  end

  it "should compile tag parameters with param and attributes" do
    compile_in_template("<foo><abc: param='x' a='b'/></foo>").should ==
      '<% _output(foo({}, {:abc => merge_tag_parameter(proc { [{:a => "b"}, {}] }, all_parameters[:x]), })) %>'
  end

  it "should compile tag parameters with param and a tag body" do
    compile_in_template("<foo><abc: param>ha!</abc></foo>").should ==
      '<% _output(foo({}, {:abc => merge_tag_parameter(' +
      'proc { [{}, { :default => proc { |_abc__default_content| new_context { %>ha!<% } }, }] }, all_parameters[:abc]), })) %>'
  end

  it "should compile tag parameters with param and nested parameters" do
    compile_in_template("<foo><baa: param><x:>hello</x:></baa:></foo>").should ==
      '<% _output(foo({}, {:baa => merge_tag_parameter(' +
      'proc { [{}, {:x => proc { [{}, { :default => proc { |_x__default_content| new_context { %>hello<% } }, }] }, }] }, all_parameters[:baa]), })) %>'
  end

  # --- Compilation: Calling tags with parameters --- #

  it "should compile tag parameters as procs" do
    compile_dryml("<foo><x:>hello</x><y:>world</y:></foo>").should ==
      '<% _output(foo({}, {' +
      ':x => proc { [{}, { :default => proc { |_x__default_content| new_context { %>hello<% } }, }] }, ' +
      ':y => proc { [{}, { :default => proc { |_y__default_content| new_context { %>world<% } }, }] }, })) %>'
  end

  it "should compile tag parameters with attributes" do
    compile_dryml("<foo><abc: x='1'>hello</abc></foo>").should ==
      '<% _output(foo({}, {:abc => proc { [{:x => "1"}, { :default => proc { |_abc__default_content| new_context { %>hello<% } }, }] }, })) %>'
  end

  it "should allow :foo as a shorthand for field='foo' on template tags" do
    compile_dryml("<foo:name/>").should == '<% _output(foo({:field => "name"}, {})) %>'
  end

  it "should compile template parameters which are themselves templates" do
    # Tag parameters with nested tag parameters are procs that return
    # a pair of hashes, the first is the attributes, the second is the
    # sub-template procs
    compile_dryml("<foo><baa: x='1'><a:>hello</a></baa></foo>").should ==
      '<% _output(foo({}, ' +
      '{:baa => proc { [{:x => "1"}, {:a => proc { [{}, { :default => proc { |_a__default_content| new_context { %>hello<% } }, }] }, }] }, })) %>'
  end

  it "should compile 'replace' parameters" do
    # A replace parameter is detected at runtime by the arity of the
    # block == 1 (for a normal parameter it would be 0). See
    # TemplateEnvironment#call_tag_parameter
    compile_dryml("<page><head: replace>abc</head></page>").should ==
      '<% _output(page({}, {:head_replacement => proc { |_head_restore| new_context { %>abc<% } }, })) %>'
  end

  it "should compile 'replace' parameters where the restore contains a default parameter call" do
    compile_dryml("<page><head: replace>abc <head restore>blah</head></head></page>").should ==

      '<% _output(page({}, {:head_replacement => proc { |_head_restore| new_context { %>abc ' +
      '<% _output(_head_restore.call({}, { :default => proc { |_head__default_content| new_context { %>blah<% } }, })) %>' +
      '<% } }, })) %>'
  end

  it "should compile 'replace' tag parameters with a default parameter call" do
    compile_dryml("<page><head: replace>abc <head restore/></head></page>").should ==

      '<% _output(page({}, {:head_replacement => proc { |_head_restore| new_context { %>abc ' +
      '<% _output(_head_restore.call({}, {})) %>' +
      '<% } }, })) %>'
  end


  # --- Compilation: Syntax sugar for before, after, append, prepend --- #

  it "should compile 'before' parameters" do
    compile_dryml("<page><before-head:>abc</before-head></page>").should ==

      '<% _output(page({}, {:head_replacement => proc { |_head_restore| new_context { %>abc' +
      '<% _output(_head_restore.call({}, {})) %>' +
      '<% } }, })) %>'
  end

  it "should compile 'after' parameters" do
    compile_dryml("<page><after-head:>abc</after-head></page>").should ==

      '<% _output(page({}, {:head_replacement => proc { |_head_restore| new_context { %>' +
      '<% _output(_head_restore.call({}, {})) %>' +
      'abc<% } }, })) %>'
  end

  it "should compile 'apppend' parameters" do
    compile_dryml("<page><append-head:>:o)</append-head></page>").should ==

      '<% _output(page({}, {:head => proc { [{}, { :default => proc { |_head__default_content| new_context { %>' +
      '<%= _head__default_content && _head__default_content.call %>:o)' +
      '<% } } } ] }, })) %>'
  end

  it "should compile 'prepend' parameters" do
    compile_dryml("<page><prepend-head:>:o)</prepend-head></page>").should ==

      '<% _output(page({}, {:head => proc { [{}, { :default => proc { |_head__default_content| new_context { %>' +
      ':o)<%= _head__default_content && _head__default_content.call %>' +
      '<% } } } ] }, })) %>'
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
    eval_dryml(%(<p class="big" id="x" merge-attrs="&{:class => 'small', :id => 'y', :a => 'b'}"/>)).
      should be_dom_equal_to('<p class="big small" id="y" a="b"/>')
  end

  it "should support attribute merging of all extra attributes on static tags" do
    eval_dryml(%(<def tag="x"><p class="big" id="x" merge-attrs/></def>
                 <x class='small' id='y' a='b'/>)).
      should be_dom_equal_to('<p class="big small" id="y" a="b"/>')
  end


  # --- Tags without named parameters --- #


  def eval_with_defs(dryml)
    eval_dryml(<<-END + dryml).strip
      <def tag="do"><%= parameters.default %></def>

      <def tag="t">plain tag</def>

      <def tag="t-attr" attrs="my-attr">it is <%= my_attr %></def>

      <def tag="t-body">( <do param="default">hmm</do> )</def>

      <def tag="merge-attrs-example"><p merge-attrs>hi</p></def>
    END
  end

  it "should call tags" do
    eval_with_defs("<t/>").should == "plain tag"
  end


  it "should call tags passing attributes" do
    eval_with_defs("<t-attr my-attr='10'/>").should == "it is 10"
  end

  it "should call tags with content (default parameter)" do
    eval_with_defs("<t-body>foo</t-body>").should == "( foo )"
  end

  it "should allow parameters to have a default" do
    eval_with_defs("<t-body/>").should == "( hmm )"
  end

  it "should provide access to the default parameter content" do
    eval_with_defs("<t-body>[<param-content/>]</t-body>").should == "( [hmm] )"
  end

  it "should support merge-attrs on static tags" do
    eval_with_defs('<merge-attrs-example class="x"/>').should == '<p class="x">hi</p>'
  end

  it "should make the declared attributes available via the 'attrs-for' method" do
    eval_with_defs('<%= attrs_for(:t_attr).inspect %>').should == '[:my_attr]'
  end

  it "should allow undeclared attributes to be extracted from 'attributes'" do
    eval_dryml("<def tag='t'><%= attributes[:my_attribute] %></def><t my-attribute='123'/>").should == "123"
  end



  # --- Parameters --- #

  def eval_with_templates(dryml)
    eval_dryml(<<-END + dryml).strip
      <def tag="do"><%= parameters.default %></def>

      <def tag="defined" attrs="a, b">a is <%= a %>, b is <%= b %>, body is <do param="default"/></def>

      <def tag="t">plain template</def>

      <def tag="static-merge"><p>a <b name="big" param>bold</b> word</p></def>

      <def tag="empty-static-merge"><img name="big" src="..." param/></def>

      <def tag="def-tag-merge">foo <defined param b="3">baa</defined>!</def>

      <def tag="nested-static-merge">merge StaticMerge: <static-merge param/></def>

      <def tag="parameter-merge">parameter merge: <static-merge><b: param/></static-merge></def>
    END
  end

  it "should add attributes to static tags when merging" do
    eval_with_templates("<static-merge><b: onclick='alert()'/></static-merge>").should ==
      '<p>a <b name="big" onclick="alert()">bold</b> word</p>'
  end

  it "should override attributes on static tags when merging" do
    eval_with_templates("<static-merge><b: name='small'/></static-merge>").should ==
      '<p>a <b name="small">bold</b> word</p>'
  end

  it "should replace tag bodies on static tags when merging" do
    eval_with_templates('<static-merge><b:>BOLD</b></static-merge>').should ==
      '<p>a <b name="big">BOLD</b> word</p>'
  end

  it "should add attributes to defined tags when merging" do
    eval_with_templates('<def-tag-merge><defined: a="2"/></def-tag-merge>').should ==
      'foo a is 2, b is 3, body is baa!'
  end

  it "should override attributes on defined tags when merging" do
    eval_with_templates('<def-tag-merge><defined: b="2"/></def-tag-merge>').should ==
      'foo a is , b is 2, body is baa!'
  end

  it "should replace tag bodies on defined tags when merging" do
    eval_with_templates('<def-tag-merge><defined:>zip</defined></def-tag-merge>').should ==
      'foo a is , b is 3, body is zip!'
  end

  it "should leave non-merged tags unchanged" do
    eval_with_templates('<static-merge></static-merge>').should ==
      '<p>a <b name="big">bold</b> word</p>'
  end

  it "should merge into static tags with no body" do
    eval_with_templates("<empty-static-merge><img: name='small'/></empty-static-merge>").should ==
      '<img name="small" src="..." />'
  end

  it "should merge template parameters into nested templates" do
    eval_with_templates('<nested-static-merge><static-merge:><b: name="small"/></static-merge></nested-static-merge>').should ==
      'merge StaticMerge: <p>a <b name="small">bold</b> word</p>'
  end

  it "should merge the body of template parameters into nested templates" do
    eval_with_templates('<nested-static-merge><static-merge:><b:>BOLD</b></static-merge></nested-static-merge>').should ==
      'merge StaticMerge: <p>a <b name="big">BOLD</b> word</p>'
  end

  it "should allow param names to be defined dynamically" do
    eval_dryml('<def tag="t"><p param="& :a.to_s + :b.to_s"/></def>' +
               '<t><ab: x="1"/></t>').should == '<p x="1" />'
  end

  it "should allow params to be defined on other params" do
    eval_with_templates('<parameter-merge><b: name="small">foo</b></parameter-merge>').should ==
      'parameter merge: <p>a <b name="small">foo</b> word</p>'
  end

  it "should allow parameter bodies to be restored with static tag params" do
    eval_with_templates("<static-merge><b:>very <param-content/></b></static-merge>").should ==
      '<p>a <b name="big">very bold</b> word</p>'
  end

  it "should allow parameter bodies to be restored with defined tag params" do
    eval_with_templates("<def-tag-merge><defined:>hum<param-content/></defined></def-tag-merge>").should ==
      'foo a is , b is 3, body is humbaa!'
  end

  it "should insert the correct param-content in nested merged template parameters" do
    eval_dryml("<def tag='t1'><p param>t1 default</p></def>" +
               "<def tag='t2'><t1 merge><p: param><param-content/> - t2 default</p></t1></def>" +
               "<t2><p:><param-content/>!</p></t2>").should == "<p>t1 default - t2 default!</p>"
  end

  it "should accumulate attributes through nested merged template parameters" do
    eval_dryml("<def tag='t1'><p: class='c1' c='c' param/></def>" +
               "<def tag='t2'><t1: merge/></def>" +
               "<def tag='t3'><t2: merge><p: class='c2' b='b' param/></t2></def>" +
               "<t3><p: class='call' a='a'/></t3>").should be_dom_equal_to("<p class='c1 c2 call' a='a' b='b' c='c'/>")
  end

  # --- Replacing Parameters --- #

  it "should allow template parameters to be replaced" do
    eval_with_templates('<static-merge><b: replace>short</b></static-merge>').should ==
      '<p>a short word</p>'
  end

  it "should allow template parameters to be replaced and then re-instated" do
    eval_with_templates('<nested-static-merge><static-merge: replace>Come back: <static-merge restore/></static-merge></nested-static-merge>').should ==
      'merge StaticMerge: Come back: <p>a <b name="big">bold</b> word</p>'
  end

  it "should allow template parameters to be replaced and then re-instated with different attributes" do
    eval_with_templates('<static-merge><b: replace>short <b restore name="small"/></b></static-merge>').should ==
      '<p>a short <b name="small">bold</b> word</p>'
  end

  it "should allow template parameters to be replaced and then re-instated with different content" do
    eval_with_templates('<static-merge><b: replace>short <b restore>big</b></b></static-merge>').should ==
      '<p>a short <b name="big">big</b> word</p>'
  end

  it "should allow restored parameters to themselves be parameters" do
    eval_with_templates('<def tag="restore-param"><static-merge><b: replace>short <b restore param>big</b></b></static-merge></def>' +
                        '<restore-param><b:>very big</b:></restore-param>').
      should == '<p>a short <b name="big">very big</b> word</p>'
  end

  it "should restore overridden parameters" do
    eval_dryml(%(
      <def tag='foo'><parameters.default/></def>
      <def tag='one'><foo param>a heading</foo></def>
      <def tag='two'><one merge><foo: param>new heading</foo:></one></def>
      <two><foo: replace><foo restore/></foo:></two>
    )).should == "new heading"
  end

  it "should restore overridden parameters on static tags" do
    eval_dryml(%(
      <def tag='one'><h1 param>a heading</h1></def>
      <def tag='two'><one merge><h1: param>new heading</h1:></one></def>
      <two><h1: replace><h1 restore/></h1:></two>
    )).should == "<h1>new heading</h1>"
  end

  # --- Append, Prepend, Before & After --- #

  it "should allow content to be inserted before template parameters" do
    eval_with_templates('<static-merge><before-b:>:o)</before-b></static-merge>').should ==
      '<p>a :o)<b name="big">bold</b> word</p>'
  end

  it "should allow content to be inserted after template parameters" do
    eval_with_templates('<static-merge><after-b:>:o)</after-b></static-merge>').should ==
      '<p>a <b name="big">bold</b>:o) word</p>'
  end

  it "should allow content to be prepended to the content of template parameters" do
    eval_with_templates('<static-merge><prepend-b:>:o)</prepend-b></static-merge>').should ==
      '<p>a <b name="big">:o)bold</b> word</p>'
  end

  it "should allow content to be appended to the content of template parameters" do
    eval_with_templates('<static-merge><append-b:>:o)</append-b></static-merge>').should ==
      '<p>a <b name="big">bold:o)</b> word</p>'
  end

  # --- Merge Params --- #


  it "should support merge_param on template calls" do
    tags = %(<def tag="page"><h1 param='title'/><div param='footer'/></def>
             <def tag="my-page"><page merge-params><footer:>the footer</footer></page></def>)

    eval_dryml(tags + "<my-page><title:>Hi!</title></my-page>").should == '<h1>Hi!</h1><div>the footer</div>'
  end


  # --- Polymorphic Tags --- #

  it "should allow tags to be selected based on types" do
    tags = %(<def tag="do"><%= parameters.default %></def>
             <def tag="t" for="string">A string</def>
             <def tag="t" for="boolean">A boolean</def>)

    eval_dryml(tags + '<do with="&\'foo\'"><%= call_polymorphic_tag(:t) %></do>').should == "A string"
    eval_dryml(tags + '<do with="&false"><%= call_polymorphic_tag(:t) %></do>').should == "A boolean"
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
    tags = %(<def tag="do"><%= parameters.default %></def>
             <def tag="template"><do:name><p param/></do></def>)
    context_eval(a_user, tags + '<template><p:><%= this %></p:></template>').should == '<p>Tom</p>'
  end


  # --- <set> --- #

  it "should provide <set> to create local variables" do
    eval_dryml("<set x='&1' y='&2'/><%= x + y %>").should == '3'
  end

  it "should support assignment to dotted names with <set>" do
    eval_dryml("<set s='&Struct.new(:a).new'/><set s.a='&10'/><%= s.a %>").should == '10'
  end

  it 'should interpolate #{...} blocks in attributes of any tag' do
    tag = '<def tag="t" attrs="x"><%= x %></def>'

    eval_dryml(tag + "<t x='#{1+2}'/>").should == '3'
    eval_dryml(tag + "<t x='hey #{1+2} ho'/>").should == 'hey 3 ho'

    eval_dryml(tag + "<p class='#{1+2}'/>").should == "<p class='3'/>"
    eval_dryml(tag + "<p class='hey #{1+2} ho'/>").should == "<p class='hey 3 ho'/>"
  end


  # --- <set_scoped> --- #

  it "should support scoped variables" do
    tags =
      "<def tag='t1'><set-scoped my-var='ping'><%= parameters.default %></set-scoped></def>" +
      "<def tag='t2'><set-scoped my-var='pong'><%= parameters.default %></set-scoped></def>"
    eval_dryml(tags + "<t1><%= scope.my_var %></t1>").should == 'ping'
    eval_dryml(tags + "<t1><t2><%= scope.my_var %></t2> <%= scope.my_var %></t1>").should == 'pong ping'
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

  it "should alow static tags to be conditional with the 'if' attribute" do
    eval_dryml("<p if='&false'/>").should == ""
    eval_dryml("<p if='&true'/>").should == "<p />"

    eval_dryml("<p if='&false'>hello</p>").should == ""
    eval_dryml("<p if='&true'>hello</p>").should == "<p>hello</p>"
  end

  it "should alow static tags to be repeated with the 'repeat' attribute" do
    eval_dryml('<img repeat="&[1,2,3]" src="#{this}" />').should ==
      '<img src="1" /><img src="2" /><img src="3" />'

    # Make sure <%= %> doesn't break
    eval_dryml('<img repeat="&[1,2,3]" src="<%= this %>" />').should ==
      '<img src="1" /><img src="2" /><img src="3" />'
  end

  it "should alow defined tags to be repeated with the 'repeat' attribute" do
    eval_dryml('<def tag="t"><%= this %></def><t repeat="&[1,2,3]"/>').should == '123'
  end

  it "should allow <else> to be used with the if attribute" do
    eval_dryml("<p if='&false'/><%= Hobo::Dryml.last_if %>").should == "false"
  end


  # --- Whitespace Suppression --- #

#  it "should remove allow newlines to be removed by adding a ' -' at the end of a line" do
#    src = <<-END
#<def tag="t"> -
#  My Tag -
#</def>
#<p><t/></p>
#END
#    eval_dryml(src).should == "<p>My Tag</p>"
#  end


  # --- Testing for parameters --- #

  it "should be possible to test for the presence of a parameter with parameters.foo?" do
    tag = "<def tag='t'><%= parameters.foo? ? 'y' : 'n' %></def>"
    eval_dryml(tag + "<t/>").should == "n"
    eval_dryml(tag + "<t><foo:/></t>").should == "y"
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

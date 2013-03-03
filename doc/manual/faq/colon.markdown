# What does the colon do in DRYML?

*What's the difference between a tag invocation without a colon,
with a colon on the end of the tag name and with a colon in the middle
of the tag name?*

Without any colons, this is an invocation of a DRYML or HTML tag.
For instance `<field-list/>` invokes the `field-list` tag in a fashion
similar to how `<br/>` inserts a break in your HTML.

With a trailing colon, this parameterizes the enclosing tag.

    <page>
      <content-body:>This will appear in the middle of your page</content-body:>
    </page>

`content-body` is not a tag in RAPID, it's a parameter to `<page>`.

What sometimes confuses people is the convention in Hobo to make the
parameter names the same as a tag name:

    <form with="&Foo.new">
      <field-list: fields="bar"/>
    </form>

In this `form for="Foo"` has a parameter called `field-list`, which we
are modifying here. It's not a coincidence that the `field-list`
parameter to `form for="Foo"` is implemented via the `field-list` tag
in Hobo.  Therefore this is similar:

    <form with="&Foo.new">
      <field-list fields="bar"/>
    </form>

If you actually try this, the form will look the same, except that it
will be missing its buttons. Why? The previous is actually a short-hand
for

    <form with="&Foo.new">
      <default:>
        <field-list fields="bar"/>
      </default:>
    </form>

In the case of `form for="Foo"`, the default parameter comprises the
entire inner contents of the form, enclosing the three innner
parameters: error-messages, field-list and actions. Our first example
told DRYML to modify the field-list parameter but leave the other two
parameters unchanged. Our last example tells it to replace the default
parameters with a field-list invocation.

There's a third tag invocation form:

    <input:bar/>

This is a shorthand for:

    <input field="bar"/>

Which is similar to:

    <input with="&this.bar"/>

except that the final form loses its place in the context hierarchy.
The context hierarchy is used by `<nested-cache>` as well as for
determining parameter names for inputs in a form.


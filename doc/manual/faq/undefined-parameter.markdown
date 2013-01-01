# Why doesn't Hobo throw an error for an undefined parameter?

A common problem encountered by newcomers to Hobo is mixing up the
parameter and invocation forms. (See previous question). Often this
means that they'll do something like this:

    <form>
      <input: name="foo" value="16"/>
    </form>

`form` doesn't have a parameter named input, so DRYML just silently
ignores it. It would be nice if it gave a nice error instead.

There are several tags that utilize the "unknown parameter" mechanism.
For example, the `<tabs/>` tag in hobo\_jquery\_ui uses it to create
tabs.

But the real reason probably is simply "it's not easy to do, so
nobody's done it yet". If you'd like to take a crack at it, we'd love
to accept a patch request. If we have to reimplement `<tabs>` and
friends, so be it. `<with-fields>` and will have to keep working,
though; there are too many widely used tags that depend on it, such as
`<field-list>` and `<table>`.

Kevin Potter (kevinpfromnm) has a nice way of remembering this
limitation: I think of the parameters as a hash of info passed to the
parent tag method. just like ruby, invalid option names often get
silently dropped. This may or not be the case behind the scenes but
think it's a nice simple way of remembering.


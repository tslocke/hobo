# Change the way non-editable fields are handled in forms

Originally written by Tom on 2008-10-28.

(Note: this recipe is about the `no-edit` attribute which was added to Edge Hobo on Oct 28th '08 in commit 8b197a3)

Hobo's default edit and new pages use the `<field-list>` tag to render the form fields. By default `<field-list>` skips any fields for which the current user does not have edit permission. This is normally what you want.

Sometimes it's not what you want. Sometimes you would rather have the current value of the field displayed. Sometimes you want the form fields to appear, but disabled (read-only). As of the commit mentioned above, those two requirements are very easily satisfied. If you want something different, of course you can still achieve it. You may have to resort to marking up the form field by field, instead of using `<field-list>` (nothing wrong with that -- never let the convenience of Rapid become a prison!).

# The `no-edit` attribute

The `no-edit` attribute tells `<input>` what to do if the current user doesn't have edit permission. There are four options:

 - view: render the current value using the `<view>` tag
 - disable: render the input as normal, but add HTML's `disabled` attribute
 - skip: render nothing at all
 - ignore: render the input normally. That is, don't even perform the edit check.
 
The default is `view`
 
`<field-list>` also takes the `no-edit` attribute. It simply forwards the value to each of the `<input>` tags it renders, with one exception: `no-edit="skip"` will cause `<field-list>` to skip both the field label *and* the `<input>` (not just the input). This is the default.

# How to have disabled inputs on an automatic form

Using the `no-edit` attribute, here's how to customise a form, say for a `Product` model, so that non-editable fields are still present in the form, but the input fields are all disabled:

    <extend tag="form" for="Product">
      <old-form><field-list: no-edit="disable"/></old-form>
    </extend>
{: .dryml}
  


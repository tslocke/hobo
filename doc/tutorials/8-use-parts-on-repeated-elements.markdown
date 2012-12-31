# Use parts on repeated elements

Originally written by Tom on 2008-10-24.

## The basics

Hobo's part mechanism makes it very easy to have parts of the page updates "ajax" style. All you do is add the `part` attribute to a tag somewhere:

    <div part="my-part">
      ... this section can be updated without reloading the page
    </div>
{: .dryml}

Then use the `update` attribute, which is supported by various Rapid tags, invcluding `<form>`
  
    <form update="my-part"> ... <submit label="Go!"/></form>
{: .dryml}

The presence of the `update` tells Rapid to generate an ajax form. When the use clicks that "Go!" button, the form is submitted in the background, the content "my-part" is re-rendered on the server, and the new content is placed onto the page.

## The problem

What if you want to have a part in a repeated section of the page? The following **will not work**:

    <ul>
      <li repeat>
        <div part="foo"> ... </div>
        <form update="foo"> ... <submit label="Go!"/></form>
      </li>
    </ul>
{: .dryml}

That makes sense, after all, which of the `<div>` elements should be updated.
  
Some points to understand about the part mechanism:

  - The part name is a global and static name, much like the name of a Rails partial

  - The string you pass to the `update` attribute is actually *not* a part name, it is a DOM ID.
  
  - By default, a tag with `part="foo"` is automatically given `id="foo"`. (that's why the first example in this recipe works - if you view-source you will see that the `<div>` has been given `id="my-part"`)
    
That should clarify why the second example doesn't work. There are multiple tags `<div id="my-part">` in the output, which is invalid.
  
## The solution

To override the part-name becoming the tags ID, just give an explicit `id` attribute. The `typed_id` helper is a handy way to generate a unique ID based on the model-name and ID of `this`. The working version of the second example is:

    <ul>
      <li repeat>
        <div part="foo" id="foo-#{typed_id}"> ... </div>
        <form update="foo-#{typed_id}"> ... <submit label="Go!"/></form>
      </li>
    </ul>
{: .dryml}

## One more tip

If it makes sense in your page to have the `<form>` *inside* the part, you can just say `update="self"`:
  
    <ul>
      <li repeat>
        <div part="foo" id="foo-#{typed_id}">
          ...
          <form update="self"> ... <submit label="Go!"/></form>
        </div>
      </li>
    </ul>
{: .dryml}

This is particularly useful in reusable tags that contain an updatable part


# Fall back to Rails techniques in your views

Originally written by Tom on 2008-10-16.

# How To: Fall back to Rails-style views.

Audience: Anyone that knows Rails-style views (ERB + Rails helpers) and is starting to learn DRYML and Rapid.

While learning to write your views using DRYML and Rapid, you might find yourself stuck trying to do something that you'd be perfectly capable of using ERB and Rails helpers. Obviously the ideal solution would be to learn the "Hobo way", but given that documentation is still a work-in-progress, you might need to just "do it the old way".

We'll start with the most extreme example of "doing it the old way" and work forward to more preferable options.


## Fall back completely to an ERB template.

Rails supports multiple template languages, and uses the file suffix to pick the right one. So simply by calling a template, say, `index.html.erb` instead of `index.dryml`, you have created a normal Rails template. Templates like this will co-exist with any DRYML pages without a problem.

The main downside to doing this is that Rails apps typically use a 'layout' to provide parts of the page that are common to all pages, while DRYML pages typically use a `<page>` tag. Your `.html.erb` file won't get the same page structure that the DRYML pages get. You could always create a Rails layout, but that's not a great idea as you'll have to manually keep it in sync with your DRYML `<page>` tag.
  
There is a better way...


## Using the `<page>` tag + ERB
  
You can solve the problem of the missing layout by sticking with the `.dryml` suffix (i.e. the page is a DRYML page), but still mark-up the entire page in ERB. You just have to wrap your ERB in the appropriate parameter of the `<page>` tag. e.g.
  
By convention, the DRYML `<page>` tag will normally provide two parameters (among many others) that will suit this purpose. If you just want to get the `<head>` section from the page tag -- things like JavaScript includes and CSS stylesheets -- and you want to provide the entire HTML body yourself, then use the `<body:>` parameter (remember, every DRYML tag that ends with a ':' is a *parameter* to the encolsing tag -- `<page>` in this case):
  
    <page>
      <body:>
        ... write a regular Rails-style ERB template here ...
      </body:>
    </page>
{: .dryml}

You will probably want more than just the `<head>` section though. You will want the "theme" of the site -- the page header, site title, nav bar etc. In this case, use the `<content:>` parameter
    
    <page>
      <content:>
        ... write a regular Rails-style ERB template here ...
      </content:>
    </page>
{: .dryml}

It's important to understand that if your application defines a custom `<page>` tag, the `<body:>` and `<content:>` parameters might not exist. These are just conventions. All of Hobo's built-in pages do provide those parameters though, so if you are working from a typical Hobo app, the above examples will work as advertised.
    

## Using small fragments of ERB and helpers

Hopefully your pages will be entirely written using DRYML and Rapid. If you find that there's just one small part you can't figure out, say a link, or a form, you can just drop down to ERB and helpers for that one thing. Here are a couple of examples.


### Links

Say you wanted to add a link to the current user's "My Account" page, which is at `/users/123/account`. Because Hobo uses normal Rails conventions of RESTful routing, you can use the familiar `link_to` helper. Here's how you would add that after the heading on one of Rapid's generated `show` pages:

    <show-page>
      <after-heading:>
        <%= link_to "My Account", :controller => "users", :action => "account", :id => current_user %>
      </after-heading:>
    </show-page>
{: .dryml}
    
### Forms

Again, because Hobo doesn't change any Rails conventions for routes or for form parameter names, if you really can't figure out how to get a DRYML/Rapid form working, you can always fall back on a "normal" Rails form. As an example, we'll completely replace the form on one of Rapid's generated 'edit' pages, say for a 'person' model. The generated `<edit-page>` tag exposes the `<form>` tag as a parameter, so we can replace it with `<form: replace>`:

    <edit-page>
      <form: replace>
        <% form_for @person do |f| %>
          <%= f.error_messages %>
          Name : <%= f.text_field :last_name %><br />
          Biography : <%= f.text_area :biography %><br />
        <% end %>
      </form:>
    </edit-page>
{: .dryml}


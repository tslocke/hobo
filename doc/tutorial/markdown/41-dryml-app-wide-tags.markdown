## Application Wide Tags

In `app/views/taglibs/application.dryml` you can define your own application-wide tags and re-define existing tags to suit your needs. 

### Customizing the `<page>` tag

The `<page>` tag provides the basic structure of your pages and is used by the generic page tags in Rapid. It is possible to define your own version of `<page>` but typically you can customize the existing definition to suit your needs with less effort. The following section shows some examples of how this is done.

#### Redefining `<page>`

`<page>` can be re-defined as shown below. This first example simply changes the default doctype.

    <def tag="page" extend-with="my-app">
      <page-without-my-app doctype="XHTML 1.0 TRANSITIONAL" merge/>
    </def>  
{: .dryml}

* *extend-with="my-app"* aliases the existing `<page>` tag as `<page-without-my-app>` before defining the new one (works like `alias_method_chain` in Ruby)
* *merge* - merge the parameters and attributes of the tag being called into the defined tag (this means that all the parameters provided by the original `<page>` definition are available from our new `<page>` definition

#### Add an extra stylesheet to the page

    <def tag="page" extend-with="my-app">
      <page-without-my-app merge>
        <stylesheets: param>
          <param-content/>
          <stylesheet name="my_stylesheet"/>
        </stylesheets:>
      </page-without-hobocentral>
    </def>
{: .dryml}

* *`<param-content/>`* - The example shows a common idiom for appending extra content on to a parameter. In this case we are adding a stylesheet to the end of the list of stylesheets. `<param-content>` means, restore the original content provided by this parameter.
* *param* - defines a new named parameter called "stylesheets" (note that `<my-tag param>` is a shortcut for `<my-tag param="my-tag">`). In this case we are exposing our new definition of "stylesheets" as a parameter that can be overriden on specific pages. This means that the original "stylesheets" parameter in `<page-without-my-app>` is no longer accessible.

#### Define your own top-level navigation

Rapid provides a generic top-level navigation that is designed to be replaced by something more specific to your app. By default navigation is implemented in a tag called `<magic-nav>` which outputs a "Home" link and the first five model controllers that have index pages. The `<page>` parameter "main-nav" makes it easy to define your own navigation:
  
    <def tag="page" extend-with="my-app">
      <page-without-my-app merge>
        <main-nav: replace>
          <navigation class="main-nav">
            <nav-item href="/">Home</nav-item>
            <nav-item with="&BlogPost">Blog</nav-item>
            <nav-item with="&Forum">Forums</nav-item>
          </navigation>
        </main-nav:>
      </page-without-my-app>
    </def>
{: .dryml}

* *`<main-nav: replace>`* - use replace when you want to remove the tag associated with a named parameter completely and insert something new in it's place.

#### Add `<meta>` tags to the page head

An example of adding `<meta>` tags to the page head:

    <def tag="page" extend-with="app">
      <page-without-app merge>
        <head:>
          <param-content/>
          <meta name="description" content="" param="meta-description"/>
          <meta name="keywords" content="" param="meta-keywords"/>
        </head:>
      </page-without-app>
    </def>
{: .dryml}

How to call the parameters:

    <page>
      <meta-description: content="My page description"/>
      <meta-keywords: content="my,page,keywords"/>
    </page>
{: .dryml}

#### Define a custom page layout

Page layouts provide a number of named parameters within the body of a page in a given structure. Rapid uses "simple-layout" as the default page layout and provides "aside-layout" as an option.

    Simple layout
        [body:]
            header:
            content:
                content-header:
                content-body:
                content-footer:
            footer:

    Aside layout
        [body:]
            header:
            content:
                main-content:
                    content-header:
                    content-body:
                    content-footer:
                aside:
            footer:

It is possible to define your own structure for a custom page layout. It is important to remember though that the generic pages defined by Rapid assume that the named parameters present in "simple-layout" will be defined.

As an example of defining a new layout we will define a three column page layout:

    Three column layout
        [body:]
            header:
            content:
                sub-navigation:
                main-content:
                    content-header:
                    content-body:
                    content-footer:
                aside:
            footer:

Our three column layout is similar to "simple-layout" so we will define our new layout based on it, overriding the "content" parameter.

    <def tag="three-column-layout"
      <simple-layout merge>
        <content: param>
          <div class="sub-navigation" param="sub-navigation"></div>
          <div class="main-content" param="main-content"><param-content/></div>
          <div class="aside" param="aside"></div>
        </content:>
      </simple-layout>
    </def>
{: .dryml}

* *`<param-content/>`* - restores the original content of "main-content" that was defined by `<simple-layout>`. This has the effect of restoring the parameters "content-header", "content-body" and "content-footer" in this new position within the layout.

`<page>` is then re-defined to use our new layout by default.

    <def tag="page" extend-with="my-app">
      <page-without-my-app layout="three-column-layout" merge>
        
        <aside: param>Default aside content</aside:>
      </page-without-my-app>
    </def>  
{: .dryml}

* *attrs="layout"* defines a named attribute that will automatically be converted to a Ruby local variable. This allows us to override the default choice of layout on particular pages.

### `<app-name>`

By default Rapid calls the tag `<app-name>` to display the application name in the page header and page title. `<app-name>` is not very clever so it is a good idea to define `<app-name>` in application.dryml.

    <def tag="app-name">Hobocentral.net</def>
{: .dryml}

### `<card>` and `<collection>`

Rapid provides several customizable tags that are called by the generic pages. They can be entirely re-defined or customized on a "per model" basis (polymorphic behaviour). By changing these tags it is possible to customize the generic pages to a limited extent without actually editing the pages directly.

`<card>` is a generic tag designed as a "summary view" of a particular object. 

An example of defining a custom card for a particular model:

    <def tag="card" for="Forum">
      <div class="card forum">
        <a/> 
        <span class="count">
          <count:topics_count label="topic"/>, <count:posts_count label="post"/>
        </span>
        <view:description truncate="100"/>
      </div>
    </def>
{: .dryml}

`<collection>` expects a list of objects and by default outputs a list of cards.

An example of defining a custom collection for a particular model:

    <def tag="collection" for="ForumTopic">
      <table class="collection forum-topic">
        <thead:>
          <tr>
            <th class="topic">Topic</th>
            <th class="last-post">Last Post</th>
            <th class="replies">Replies</th>
            <th class="views">Views</th>
          </tr>
        </thead:>
        <tr:>
          <td class="topic"><a/></td>
          <td class="last-post"><forum-post-summary/></td>
          <td class="replies"><view:replies.count/></td>
          <td class="views"><view:view_counter/></td>
        </tr:>
      </table>
    </def>
{: .dryml}

TODO: Add an example of re-defining `view`, `input`


Next: [Customizing the Generic Pages](42-dryml-generic-pages.html)
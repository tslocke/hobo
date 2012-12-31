# Replicate the look-and-feel of an existing site

Originally written by Tom on 2008-10-28.

This recipe answers [how can I change the front page?](/questions/54-how-can-i-change-the-front)

Say we want a new Hobo app to have the same look-and-feel of an existing site. The really big win is if we can have this look and feel happen to our new app almost 'automatically'. We want to be able to develop at "Hobo speed", and have the look and feel "just happen". This is not trivial to set up, but once it is the pay-back in terms of development agility will be more than worth it. That is the topic of this how-to.

Given that our current sponsors - Barquin International - find themselves in this exact situation, we'll base this recipe on a look-and-feel that they frequently have to provide. One example is the CSREES website ([www.csrees.usda.gov](http://www.csrees.usda.gov/)):

  ![CSREES Home page][5]
  
Note that, for now at least, this recipe will document how to create a *close approximation* to this theme. In particular, we're going to skip some of the details that cannot be implemented without resorting to images. This is just to keep the from recipe getting to long and complicated.

## Introduction
  
This will be as much a guide to general web-development best-practice, as it will be a lesson in Hobo and DRYML. The mantra when working with themes in Hobo is something already familiar to skilled web developers:

> Separate content from presentation

The vast majority of common mistakes that are made in styling a web-app come under this heading. If this one idea can be understood and applied, you're well on the way to:

 - Having the look-and-feel "just happen" as your site changes and evolves
 
 - Being able to change the theme in the future, without having to modify the app
 
Since CSS has been widely adopted, most web developers are familiar with this principle. So this is probably just a recap, but to remind ourselves how this works:

 - "Content" describes *what is on the page*, but not *what it will look like*. In a Hobo app content comes from tag definitions, page templates and the applications data of course.
 
 -"Presentation" describes *how the page should look*. That is, it describes fonts, colours, margins, borders, images and so on. In a Hobo app the presentation is handled essentially the same way as with any app. With CSS stylesheets and image assets.
 
Having said that, we need to inject a note a pragmatism:

 - Humans being visual animals, information can never truly be separated from the way it is displayed. The line is sometimes blurred and there are often judgement calls to be made. 
 
 - The technologies we've got to work with, in particular cross-browser support for CSS, are far from perfect. Sometimes we have to compromise.
 
There's probably an entire PhD thesis lurking in that first point, but let's move on!


## The current site

We'll start with a look at the elements of the existing site that we'll need to replicate. The main ones are:

A banner image:

![][6]

The main nav bar:

![][7]

A couple of styles of navigation panels:

![][8] ![][9]

And more navigation in the page footer

![][12]

One of the important things to notice at this stage, is that this is *not* just a "theme" in the Hobo sense of the word. Hobo themes are purely about presentation, whereas the "look and feel" of this site is a mixture of content elements and presentation.

That means we're going to be creating three things to capture this look-and-feel: tags definition, a CSS stylesheet, and some image assets.


## The current markup

The existing site makes extensive use of HTML tables for layout, and the various images in the page are present in the markup as `<img>` tags. In other words, the existing markup is very *presentational*. So rather than create tag definitions out of the existing markup, we'll be recreating the site using clean, semantic markup and CSS.

The other advantage of re-creating the markup is that it will be easier to follow Hobo conventions. There's no particular need to do this, but it makes it a great deal easier to jump from one Hobo app to the next.


## Building the new app

Let's do this properly and actually follow along in a blank Hobo app. At the end of the recipe we'll see how we could package this look-and-feel up and re-use it another app. To follow along, you should use Firefox and the Firebug extension.

    $ hobo csreesdemo
    $ cd csreesdemo
    $ ruby script/generate hobo_migration

If you fire up the server, you'll see the default Hobo app of course:

![][14]

Now we can start to make it look like the page we're after. We'll take it step by step.


### Main background and width

My trusty TextMate colour picker tells me that the CSREES background colour is #A8ACB6. Firebug tells me (click the inspect button, then click on the background) that the CSS rule that sets the current background comes from `clean.css` and looks like:

    html, body { background:#193440 }
    
So I'm going to add this rule to `public/stylesheets/application.css`:

  html, body { background:#A8ACB6 }
  
Again, using Firebug (by clicking on the `<body>` tag in the HTML window) I can see that the width is set on the body tag. 
  
    body { ... width: 960px; ... }
    
Back in CSREES, I can right click the banner image and chose "View Image", and Firefox tells me it's width is 766 pixels. So in `application.css` I add

    body { width: 766px; }
    
Note we've not changed any markup yet - that's how we like it.

    
### Account navigation

These are the log-in and sign-up links in the top right. They are not on the CSREES site, but if the app needed them, the place they are in now would be fine, so we'll leave them where they are.


### Search 

The page header has a search-field which we don't want. To get rid of this we'll customise the `<page>` tag. This will then become the place where we make various changes to `<page>`:
  
    <extend tag="page">
      <old-page merge without-live-search>
      </old-page>
    </extend>
{.dryml}

So now we *have* made a change to the markup, but that makes perfect sense, because here we wanted to change *what's on the page* not *what stuff looks like*.


### The Banner
    
Again, using Firefox's "View Image", it turns out that the existing banner is in fact two images. This one:

![][15]

And this one:

![][16]

Too add these images without changing the markup, we need to use CSS's background-image feature. One major limitation of CSS is that you can only have one background image per element. That won't be a problem, but to understand our approach, first take a look at a simplified view of the page markup that we're working with:

    <html>
      <head>...</head>
      <body>
        <div class="page-header">
          <h1 class="app-name">Csreesdemo</h1>
        </div>
        ...
      </body>
    </html>
{.dryml}

Notice that this image

![][15]

Is essentially a graphical version of that `<h1>` tag, so we'll use CSS to make that same `<h1>` be rendered as an image. The existing text will be hidden, by moving it way out of the way with a `text-indent` rule. First we need to save that image into our public/images folder. The CSS to add to `application.css` is:
  
    div.page-header { padding: 0; }

    div.page-header h1.app-name {
        text-indent: -10000px;
        background: url(../images/banner_csrees.gif) no-repeat;
        padding: 0; margin: 0;
        height: 62px;

    }

OK that was a bit of a leap. Why `padding: 0px` for the page-header, for example? The fact of the matter is, that working with CSS is all about trial and error. Using Firebug to figure out what rules are currently in effect, flipping back and forth between the stylesheet in your editor and the browser. Try experimenting by taking some of those rules out and you'll see why each is needed.

Now for the photo part of the banner. Again, save it to public/images, then add some extra properties to the `div.page-header` selector, so it ends up like:

    div.page-header {
        padding: 0; 
        background: url(../images/banner_photo.jpg) no-repeat 0px 62px;
        height: 106px;
    }
    
Taking shape now, except the main nav is splatted on top of the photos.

### Main Navigation

The existing navigation bar is created entirely with images. It's quite common to do this, as it gives total control over fonts, borders, and other visual effects such as colour gradients. The downside is that you have to fire up your image editor every time there's a change to the navigation. This doesn't sit very well with our goal to be able to make changes quickly and easily. So for this recipe we're going to go implement the nav-bar without resorting to images. We'll lose the bevel effect, but some might think the end result is actually better - cleaner, clearer and more professional looking. Bevelled edges are so 1998 :o)

Our app only has a home page right now, so first let's define a fake nav bar to work with. In `application.dryml`:

    <def tag="main-nav">
      <navigation class="main-nav">
        <nav-item href="">Home</nav-item>
        <nav-item href="">About Us</nav-item>
        <nav-item href="">Grants</nav-item>
        <nav-item href="">Forms</nav-item>
        <nav-item href="">Newsroom</nav-item>
        <nav-item href="">Help</nav-item>
        <nav-item href="">Contact Us</nav-item>
      </navigation>  
    </def>
{.dryml}

Use Firebug's "Inspect" button to find the nav-bar. You'll see that it's rendered as a `<ul>` list, which is generally considered good practice; it is a list of links after all. There's several things wrong with the appearance of the navigation at this point:
  
 - It's in the wrong place - we want to move it down and to the right.
 - Needs to be shorter, and the spacing of the items needs fixing
 - The font needs to be smaller, and not bold
 - The background colour needs to change, as do the colours when you mouse-over a link
 
Now this is not a CSS tutorial, so we're not going to explain every last detail, but we'll build it up in a few steps which will help to illustrate what does what. First update the rules for `div.page-header` so they look like:

    div.page-header {
        padding: 0; 
        background: white url(../images/banner_photo.jpg) no-repeat 0px 62px;
        height: 138px;
    }

And add:

    div.page-header .main-nav {
        position: absolute; bottom: 0; right: 0; 
    }
  
The nav-bar still looks wrong, but it's in the right place (well, nearly). We'll now fix the sizing and placement. Update the new rule (`div.page-header .main-nav`) and add two new ones, like this:

    div.page-header .main-nav {
        position: absolute; bottom: 0; right: 0; 
        height: 21px; width: 100%; line-height: 21px; padding: 0; 
        text-align: right; 
    }

    div.page-header .main-nav li {
        margin: 0; padding: 0 0 0 4px;
        display:inline; float:none;
    }

    div.page-header .main-nav li a {
        padding: 3px 8px; margin: 0;
        font-weight: normal; display:inline; font-size: 12px;
    }

And finally we'll add the colours. Just to avoid confusion, here's the full stylesheet so far:

    html, body { background:#A8ACB6 }
    body { width: 766px; }

    div.page-header {
        padding: 0; 
        background: white url(../images/banner_photo.jpg) no-repeat 0px 62px;
        height: 138px;
    }

    div.page-header h1.app-name {
        text-indent: -10000px;
        background: url(../images/banner_csrees.gif) no-repeat;
        padding: 0; margin: 0;
        height: 62px;
    }

    div.page-header .main-nav {
        position: absolute; bottom: 0; right: 0; 
        height: 21px; width: 100%; line-height: 21px; padding: 0; 
        text-align: right; 
        background: #313367; 
    }

    div.page-header .main-nav li {
        margin: 0; padding: 0 0 0 4px;
        display:inline; float:none;
        border-left: 1px dotted #eee; background: #313367;
    }

    div.page-header .navigation.main-nav li a {
        padding: 3px 8px; margin: 0;
        font-weight: normal; display:inline; font-size: 12px;
        background: transparent;
        color: #eee;
    }

    div.page-header .navigation.main-nav li a:hover {
        background: #A9BACF; color: black;
    }
    
Note that we had to make the last two selectors a bit more specific, in order to ensure that they take precedence over rules in the Clean theme.

The page header should be done at this point:

![][17]


### The sidebars

The existing site has both left and right sidebars. We'll add those now. The first step is to add the three content sections the `<page>` tag. We've already extended `<page>`, so modify the DRYML you already have to look like:
  
    <extend tag="page">
      <old-page merge without-live-search>
        <content: replace>
          <section-group class="page-content">
            <aside param="aside1"/>
            <section param="content"/>
            <aside param="aside2"/>
          </section-group>
        </content:>
      </old-page>
    </extend>
{.dryml}

We've replaced the existing `<content:>` with a `<section-group>` that contains our two `<aside>` tags and the main `<section>`.
  
To try this out, we'll insert some dummy content in `app/views/front/index.dryml`. Edit that file as follows:

    <page title="Home">
      <body: class="front-page"/>
      <aside1:>Aside 1</aside1:>
      <content:>Main content</content:>
      <aside2:>Aside 2</aside2:>
    </page>
{.dryml}

You should see something like:

![][18]

Obviously we've got a bunch of styling to do. First though, let's add the content for the left sidebar. This is the "search and browse" panel, which is on every page of the site, so let's define it as a tag:

    <def tag="search-and-browse" attrs="current-subject">
      <div class="search-and-browse">
        <div param="search">
          <h3>Search CSREES</h3>
          <form action="">
            <input type="text" class="search-field"/>
            <submit label="Go"/>
          </form>
          <p class="help"><a href="">Search Help</a></p>
        </div>
        <div param="browse-by-audience">
          <h3>Browse by Audience</h3>
          <select-menu first-option="Information for..." options="&[]"/>  
        </div>
        <div param="browse-by-subject">
          <h3>Browse by Subject</h3>
          <navigation current="&current_subject">
            <nav-item href="/">Agricultural & Food Biosecurity</nav-item>
            <nav-item href="/">Agricultural Systems</nav-item>
            <nav-item href="/">Animals & Animal Products</nav-item>
            <nav-item href="/">Biotechnology & Geneomics</nav-item>
            <nav-item href="/">Economy & Commerce</nav-item>
            <nav-item href="/">Education</nav-item>
            <nav-item href="/">Families, Youth & Communities</nav-item>
          </navigation>
        </div>
      </div>        
    </def>
{.dryml}

A few points to note about that markup:

 - We've tried to maker the markup as "semantic" as possible -- it describes what the content *is*, not what it looks like.

 - We've added a few `param`s, so that individual pages can customise the search-and-browse panel. Each `param` also gives us a CSS class of the same name, so we can target those in our stylesheet.
 
 - We've used `<navigation>` for the browse-by-subject links. This gives us the ability to highlight the current page as the user browses.

Because the search-and-browse panel appears on every page, lets call it from our master page tag (`<extend tag="page">`). Change:
  
    <aside param="aside1"/>
{.dryml}

To:

    <aside param="aside1"><search-and-browse/></aside>
{.dryml}


Then remove the `<aside1:>Aside 1</aside1:>` parameter from `front/index.dryml`.

Now we need to style this panel. After a good deal of experimentation, we get to the following CSS:

    div.page-content, div.page-content .aside { background: white; }

    .aside1 { width: 173px; padding: 10px;}

    .search-and-browse {
        background: #A9BACF;
        border: 1px solid #313367;
        font-size: 11px;
        margin: 4px;
    }

    .search-and-browse h3 {
        background: #313367; color: white;
        margin: 0; padding: 3px 5px;
        font-weight: normal; font-size: 13px; 
    }

    .search-and-browse a { background: none; color: #000483;}

    .search-and-browse .navigation { list-style-type: circle; }
    .search-and-browse .navigation li { padding: 3px 0; font-size: 11px; line-height: 14px;}
    .search-and-browse .navigation li a { border:none;}

    .search-and-browse .search form { margin: 0 3px 3px 3px;}
    .search-and-browse .search p { margin: 3px;}
    .search-and-browse .search-field { width: 120px;}
    .search-and-browse .submit-button { padding: 2px;}

    .search-and-browse .browse-by-audience select { margin: 5px; 3px; width: 92%;}
    
With that added to `application.css` you should see:

![][19]

OK - let's switch to the right-hand sidebar.

If you click around [the site](http://www.csrees.usda.gov/) you'll see the right sidebar is always used for navigation panels, like this one:

![][9]

You'll also notice it's missing from some pages, which is as easy as:

    <page without-aside2/>
{.dryml}

It seems like a good idea to define a tag that creates one of these panels, say:

    <nav-panel>
      <heading:>Quick Links</heading:>
      <items:>
        <nav-item href="/">A-Z Index</nav-item>
        <nav-item href="/">Local Extension Office</nav-item>
        <nav-item href="/">Jobs and Opportunities</nav-item>
      </items:>
    </nav-panel>
{.dryml}  

We've re-used the `<nav-item>` tag as it gives us an `<li>` and an `<a>` which is just what we need here.
  
Now add the definition of `<nav-panel>` to your `application.dryml`:

    <def tag="nav-panel">
      <div class="nav-panel" param="default">
        <h3 param="heading"></h3>
        <div param="body">
          <ul param="items"/>
        </div>
      </div>
    </def>
{.dryml}

Notice that we defined two parameters for the body of the panel. Callers can either provide the `<items:>` parameter, in which case the `<ul>` wrapper is provided, or, in the situation where the body will not be a single `<ul>`, they can provide the `<body:>` parameter.

OK let's throw one of these things into our page. Here's what `front/index.dryml` needs to look like:

    <page title="Home">
      <body: class="front-page"/>
      <content:>Main content</content:>
      <aside2:>

        <nav-panel>
          <heading:>Grants</heading:>
          <items:>
            <nav-item href="/">National Research Initiative</nav-item>
            <nav-item href="/">Small Business Innovation Research</nav-item>
            <nav-item href="/">More...</nav-item>
          </items:>
        </nav-panel>

        <nav-panel>
          <heading:>Quick Links</heading:>
          <items:>
            <nav-item href="/">A-Z Index</nav-item>
            <nav-item href="/">Local Extension Office</nav-item>
            <nav-item href="/">Jobs and Opportunities</nav-item>
          </items:>
        </nav-panel>

      </aside2:>
    </page>
{.dryml}


And here's the associated CSS -- add this to the end of your `application.css`:

    .aside2 { margin: 0; padding: 12px 10px; width: 182px;}
    .nav-panel {border: 1px solid #C9C9C9; margin-bottom: 10px;}
    .nav-panel h3 {background:#A9BACF; color: #313131; font-size: 13px; padding: 3px 8px; margin: 0;}
    .nav-panel .body {background: #DAE4ED; color: #00059A; padding: 5px;}
    .nav-panel .body a {color: #00059A; background: none;}
    .nav-panel ul {list-style-type: circle;}
    .nav-panel ul li { margin: 5px 0 5px 20px;}
    
### Main content

The main content varies a lot from page to page, so let's just make sure that the margins are OK, and leave it at that. First we need some content to work with, so in `front/index.dryml`, replace:

    <content:>Main content</content:>
{.dryml}

With:

    <content:>
      <h2>Cooperative State Research, Education and Extension Service</h2>
      <p>Main content goes here...</p>
    </content:>
{.dryml}  

On refreshing the browser it seems there's nothing else to do. That looks fine.

### The footer

The footer is the same throughout the site. Let's define it as a tag and add it to our main `<page>` tag. Here's the definition for `application.dryml`:
  
    <def tag="footer-nav">
      <div class="footer-nav">
        <ul>
          <nav-item href="/">CSREES</nav-item>
          <nav-item href="/">USDA.gov</nav-item>
          <nav-item href="/">Site Map</nav-item>
          <nav-item href="/">Policies and Links</nav-item>
          <nav-item href="/">Grants.gov</nav-item>
        </ul>
      </div>
    </def>
{.dryml}

And add this parameter to the `<extend tag="page">`:
  
    <footer: param><footer-nav/></footer:>
  
And finally, the CSS. To get the corner graphic that we've used here, you need to right-click and "Save Image As" on the bottom left corner in the existing site:

    .page-footer {
        background: white url(../images/footer_corner_left.gif) no-repeat bottom left;
        overflow: hidden; height: 100%;
        border-top: 1px solid #B8B8B8;
        font-size: 10px; line-height: 10px;
        padding: 5px 0 15px 20px;
    }

    .page-footer ul { list-style-type: none; }
    .page-footer ul li { float: left; border-right: 1px solid #2A049A; margin: 0; padding: 0 5px;}
    .page-footer ul li a {border:none; color: #2A049A;}
    
There's one CSS trick in there that is work a mention. In the `.page-footer` section, we've specified:
  
    overflow: hidden; height: 100%;

This is the famous "self clearing" trick. Because all the content in the footer is floated, without this trick the footer looses its height. 

That pretty much brings us to the end of the work of reproducing the look and feel. We should now be able to build out our application, and it will look right "automatically". In practice you always run into small problems here and there and need to dive back into CSS to tweak things, but the bulk of the job is done.

The next question is - how could we make several apps look like this without repeating all this code?


# A look-and-feel plugin

To re-use this work across many apps, we'll use the standard Rails technique - create a plugin. The plugin will contain:

 - A DRYML taglib with all of our tag definitions
 
 - A `public` directory, containing our images and stylesheets


## Creating the plugin
 
Somehow the idea of "creating a plugin" seems like a big deal, but it's there's really nothing to it. Pretty much all we're going to do is move a few files into different places. 

    $ mkdir vendor/plugins/csrees
    $ cd vendor/plugins/csrees
    $ mkdir taglibs
    $ mkdir public
    $ mkdir public/csrees
    $ mkdir public/csrees/stylesheets
    $ mkdir public/csrees/images
    $ cd ../../..
    $ cp app/views/taglibs/application.dryml vendor/plugins/csrees/taglibs/csrees.dryml
    $ cp public/stylesheets/application.css vendor/plugins/csrees/public/csrees/stylesheets/csrees.css
    $ cp public/images/* vendor/plugins/csrees/public/csrees/images

(That last command will also copy `rails.png` into the plugin, which you probably want to delete).

We've copied the whole of `application.dryml` into our plugin, because nearly everything in there belongs in the plugin, but it does need some editing:

 - At the top, remove all of the includes, the `<set-theme>` and the definition of `<app-name>`
 
 - We need to make sure our stylesheet gets included, so add the following parameter to the call to `<old-page>`:
 
        <append-stylesheets:>
          <stylesheet name="/csrees/stylesheets/csrees.css"/>
        </append-stylesheets:>


## Installing the plugin

To try out the plugin, create a new blank Hobo app. There are then three steps to install and setup the plugin:

**To install the plugin** copy `vendor/plugins/csrees` from the app we've been working on, into `vendor/plugins` in the new app. To setup the plugin, we just need to include the taglib, and copy the public assets into our `public` directory

**To install the taglib** add 

    <include src="csrees" plugin="csrees"/>
    
to `application.dryml`. It must be added *after* the `<set-theme>` tag.

**To install the public assets**:

    $ cp -R vendor/plugins/csrees/public/* public
    
That should be it - your new app will now look like the CSREES website, and the tags we defined, such as `<nav-panel>` will be available in every template.


![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-1.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-2.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-3.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-4.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-5.jpg)

![image](/images/original_Cooperative_State_Research_Education_and_Extension_Service_CSREES_-6.jpg)

![image](/images/original_Home___Csreesdemo-1.jpg)

![image](/images/original_banner_csrees.gif)

![image](/images/original_banner_photo.jpg)

![image](/images/original_Home___Csreesdemo.jpg)

![image](/images/original_Home___Csreesdemo-2.jpg)

![image](/images/original_Home___Csreesdemo-3.jpg)


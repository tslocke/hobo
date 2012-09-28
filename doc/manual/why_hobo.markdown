Why Hobo?
=========

Building a web application is hard.  For example, to build a polished
application in Ruby on Rails, you need to learn Ruby, Rails, HTML, CSS
& Javascript.

Now try the [two minute
demo](http://cookbook.hobocentral.net/tutorials/two-minutes).   You've
just created a full fledged web application in under two minutes,
without knowing any of the above technologies, even though you've used
them all.

Add a few more models, and you can quickly have a fully functional
prototype without ever touching a web editor.

Tools that provide similar capabilities are very common in the very
expensive world of enterprise software, although they are quite rare
in the world of free, open-source software.

But most professionals won't touch such a Rapid Application
Development tool with a ten foot pole.  Everything works great while
you do things that are standard, things that the tool developer has
anticipated.  The vast majority of every application is quite standard
and similar from application to application.  But there's always
something about every application that's a little bit different,
that wasn't anticipated by the RAD tool developers.

For example, suppose you decided to use [Active
Scaffold](http://activescaffold.com/) in your project.  Active Scaffold
provides automatic view generation capability in a manner very similar
to Hobo.   It has the advantage that it is more mature, more polished,
more popular and better documented.   It'll work great to provide
80-99% of the views in your application.  But what do you do for the
other 1%?

It'll be frustrating, because what Active Scaffold provides will be
very close to what you need.  You'll spend hours tweaking the various
knobs that Active Scaffold provides, but it'll never work quite right.
Eventually you'll give up, and write the view yourself in plain HTML,
CSS, Javascript & Ruby/Rails.  The view won't match the rest of your
application style or function, so you end up rewriting a few more
views just to make everything match.  Eventually you'll wonder if the
effort you expended learning Active Scaffold was wasted.

Compare this with what happens in a Hobo application.  It's not (yet)
as mature as Active Scaffold, so you'll start tweaking things
earlier.  However, you'll never hit the wall.  You'll never have to
give up and abandon Hobo for part of your program.  If your needs are
substantially different from what the Hobo team has anticipated, you
will have to do a lot of tweaking, but it will be possible.

And not only will it be possible, the results of your effort can be
packaged up neatly to reuse in your current project, in a different
project or shared with the world so that others can take advantage of
your effort.

And hopefully your learning curve should be fairly linear.  To be a
true expert using Hobo you'll still have to learn HTML, CSS,
Javascript, Ruby and Rails.  On top of that, you'll also have to learn
Hobo and DRYML.  But you'll have a fully functional application at the
beginning of your learning process, and you can learn as you go.  The
more you know, the better, but you can pick it up as you go along.

Or you don't have to learn them -- you'll have a working application
from hour one.

For people that are already experts in these technologies, learning
Hobo and DRYML will provide also provide huge advantages.

The core of Hobo is DRYML -- the Don't Repeat Yourself Markup
Language.  This is a markup language designed to generate HTML while
allowing for maximum code reuse.  DRYML features several different
mechanisms to customize and parametrize DRYML reusable tags.

The simplest and most straight forward mechanism is called
"attributes".  They work very similar to attributes in HTML.  They
allow you to pass strings and ruby objects into the tag for use by the
tag.

"Parameters" allow you to pass in snippets of DRYML code to the tag.
In many cases parameters are provided so that tag users can provide
the "meat" for the output.  Other times, they are provided so that you
may replace a portion of the output if the provided default it not
appropriate.

The next level of customization would be to "extend" a tag.  Extending
a tag allows you to wrap, parametrize or change the attributes of all
invocations of the tag in your applications.  Similar to
`:alias_method_chain` in ruby, it is used much more often in DRYML.
Hobo automatically builds forms and summary views for all of the
ActiveRecord objects in your application.  Quite often these forms and
summary views (aka cards) are close but not quite what you want.  You
can extend the automatic definitions to incorporate your
customizations.  Of course, your customizations can be further
parametrized if separate invocations of the tag need to be displayed
slightly differently.

Another mechanism available is to simply replace or redefine a tag.
This often isn't as difficult as it sounds, because DRYML is so
modular.  It works well for HTML elements as large as a page and as
small as a primitive element, so you are unlikely to have to rewrite
everything -- your redefinition can be a simple composition of tags.

Finally, you can ignore the tag.  You can replace a tag invocation
with straight HTML, whether that invocation is for a small snippet on
a page or for an entire page view.

But that's not all.  I haven't discussed context, pseudo-parameters or
polymorphism -- further mechanisms that DRYML provides to customize
your output.

And DRYML is only part of what Hobo provides.  Hobo brings huge
benefits to your models and controllers as well as your views.  For
example, HoboFields provides DataMapper style declarations and
automatic migrations to your Rails 2 ActiveRecord based applications.

Another powerful concept that Hobo provides is called "Lifecycles".
Veterans may be familiar with the revolution that the [REST
model](http://en.wikipedia.org/wiki/Representational_State_Transfer)
brought to the design of web applications.  Lifecycles takes it to the
next level.   Lifecycles give you a mechanism to add a state machine
to your models, defining states and transitions.  By doing so, you
should be able to completely remove any non-REST, non-Lifecycle
external methods from your controllers.  If you cannot, it's quite
likely that there is a better way to model your problem domain.

In fact, if you decide not to adopt Hobo, I would highly encourage you
to adopt the plain Rails alternative to Lifecycles, [Acts as State
Machine](http://github.com/rubyist/aasm).  The advantage that Lifecycle
provides is that it can automatically provide controller actions and
views for every state and transition by utilizing the rest of the Hobo
framework.

Hobo provides much more.  To summarize:

  - Hobo Generators generate code that give you a full working
    application yet simultaneously provide a true skeleton rather than
    a large mass of code to copy and modify.

  - DRYML provides a very powerful markup language ensuring that you
    "never hit the Rapid Application Development wall" and enabling
    many of the other powerful features of Hobo.

  - Rapid provides a library of DRYML tags that you can use and
    reuse.  Many tags incorporate AJAX support, sometimes making it
    easier to do AJAX than it is to do things the Web 1.0 way!

  - Lifecycles give you a state machine, allowing you to fully and
    consistently model your application.

  - HoboFields allow you do declare your schema inside your model and
    perform automatic schema migrations

  - The Hobo permission system ensures that your access model is
    collected centrally in your model and consistently enforced

  - Automatic Named Scopes are a very useful addition to ActiveRecord.

  - HoboSupport provides many useful Ruby extensions

  - Subsites allow you to cleanly and easily partition your application.

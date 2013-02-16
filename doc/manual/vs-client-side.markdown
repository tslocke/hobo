Hobo vs Client Side Javascript
{.document-title}

Contents
{: .contents-heading}

- contents
{:toc}

## Introduction

A very common pattern for modern web applications is to use a thin layer for the web server, along with a thick client side web application along with native iOS and Android application.  With this architecture, all three front ends are rough peers, which brings with it certain advantages.

## Using Hobo for the Server API

Hobo as a thin layer for server API's seems like an oxymoron;  after all Rails & Hobo are fairly heavyweight.  However, this isn't as silly as it seems.  The [Rails API](
https://github.com/rails-api/rails-api) project is designed to pull in every part of Rails that is useful for Server API's and nothing that will slow that down.

Rails-API is not yet stable and Hobo does not yet work with it, but there is very little difference between stock Rails and Rails-API for server API's, so you can use stock Rails to develop server API's for now.   Hobo doesn't add a lot to such a project, but you may still find Hobo Fields, Permissions and Lifecycles useful.

## Using Hobo for the Administrative Panels

Quite typically there are large parts of your application that do not need the full power, speed and polish of native phone applications.  For example, there are often several administrative panels that will never seen by customers.  You wouldn't add these panels to your native applications -- if an admin needs to access them from a phone, they can just use your web browser.   Similarly, portions of your native applications can be deployed using an embedded web browser.   Since you do not have three separate versions of these panels, there's no need to develop separate Server API & Client Side components, you can just use Hobo for it's vastly superior speed of development

## Hobo Can Be Fast

One of the primary motivations for using a client-side framework is that they tend to perform very quickly.  It's quite likely that the user is using a powerful computer or phone to display your web pages; by utilizing the power of your user's computer you minimize the load on your web servers allowing it to serve responses quicker.

Another thing that makes client side frameworks really fast is they take good advantage of selective updating.   A traditional web application refreshes the entire page for every change.

But Hobo applications can utilize selective updating too.   37 Signals uses Rails for the very responsive Bootcamp 2.0, and [blogged about how they made it so fast](http://37signals.com/svn/posts/3112-how-basecamp-next-got-to-be-so-damn-fast-without-using-much-client-side-ui).

In fact, Hobo makes it easier than most Generic Rails or most other server side web framewoks to do hierarchical caching and selective updates.   Check out our [caching tutorial](/tutorials/caching) for more information.

## Clients aren't necessarily fast.

The PC you use for development might be fast, but an adware-laden RAM limited netbook with an out of date browser can be a lot slower.   Your clients may also be on a very slow internet connection:  shipping a large amount of Javascript to them may take a considerable amount of time.

## Ecosystem Breadth

Ruby & Rails have a very large base of very useful gems and plugins that can be used with your project.  Why reinvent the wheel when somebody else has already done so?  Additionally, Hobo can utilize the large ecosystem of jQuery plugins just as easily as client side frameworks can.

Further widening the gulf is the fact that there are so many client side frameworks and little compatibility between them.   In the Ruby world, Rails is by far the most popular framework.   Some lightweight frameworks like Sinatra are also popular, but there are no other full-featured frameworks that come anywhere close to Rails in popularity.  Client-side frameworks have several popular frameworks that aren't interoperable.   An Ember plugin is not going to work with AngularJS.

## Ecosystem Maturity

And not only is there a much larger set of gems and plugins, commonly used gems and plugins are often much more mature than their counterparts in the client-side world.   If you use an npm module, it's quite possible that you will get to discover and fix the corner cases that have already been discovered and fixed in the equivalent Ruby gem.

## Faster Development

The main reason to choose Hobo over client-side frameworks is the main reason people choose Hobo over any other server-side framework: application development speed.  Write less code, faster.
Hobo vs Node.js
{.document-title}

Contents
{: .contents-heading}

- contents
{:toc}

Node.js is what's getting all the buzz these days.   So why do we think you're better off using a Hobo stack than a stack built on Node.js?

## Javascript vs Ruby

Node.js uses Javascript, Hobo uses Ruby.   Many people have debated the relative merits of these two languages, and we're not going to add to it.  Obviously we prefer Ruby, but we also really like Javascript.   Ruby does some things better, but there are parts of Javascript that are better designed than their equivalents in Ruby.   Frankly, we feel this should be a very minor factor in your decision making; the other points are much more important.

## Blocking vs Non-Blocking

Perhaps the most striking thing about Node.js is that it's written using a non-blocking continuation passing style.  Rails & Hobo use much more conventional blocking style.   For example, if you ask the database for something in Rails, your problem will be blocked until the results are returned to you.   With Node.js, instead you give your ORM a continuation and your code keeps executing.   When the database has it's results, it calls the continuation.

The Node.js style sounds faster, but only if you have stuff to do that doesn't require those database results.   In a web application, that database call is usually core to the web application; there's not much useful work that can be done without it.

Plus, on a web server there are usually lots of other threads or processes that can use the CPU while you are blocked waiting for the database.  Generally you care about speed when your server is heavily loaded; and if it's heavily loaded there are lots of other requests that the CPU can process while it's blocked on the database and the average response time is not going to be significantly different.   When your server is lightly loaded it'll return quickly no matter what style you use.

But the non-blocking continuation passing style has significant disadvantages.   It can be awkward and difficult to write, but more importantly it is harder to debug and maintain.   In general, servers are a lot cheaper than developers.

## Node.js vs Rack

Hobo is a very different product than Node.js, they occupy much different positions in your server stack.   Hobo is built on top of Rails which is built on top of [Rack](http://rack.github.com/).   Rack is the part of the Hobo stack that's most comparable to Node.js.   But it's quite possible that you've never even heard of Rack.   Why not?   Because it just works.

## Ecosystem Breadth

Ruby & Rails have a very large base of very useful gems and plugins that can be used with your project.  Why reinvent the wheel when somebody else has already done so?

Further widening the gulf is the fact that there are so many Node.js frameworks and little compatibility between them.   In the Ruby world, Rails is by far the most popular framework.   Some lightweight frameworks like Sinatra are also popular, but there are no other full-featured frameworks that come anywhere close to Rails in popularity.  But on Node.js there are many popular frameworks, with very different philosophies and interfaces.   A plugin for FlatIron is not going to work on Meteor meaning that your framework choice is going significantly narrow the choices you have for plugins.

## Ecosystem Maturity

And not only is there a much larger set of gems and plugins, commonly used gems and plugins are also much more mature than their counterparts in the Node.js world.   If you use an npm module, it's quite possible that you will get to discover and fix the corner cases that have already been discovered and fixed in the equivalent Ruby gem.

Part of the maturity is due to Rails being around a lot older than Node, and part due to the fact that Rails is much more widely used than any of the Node.js based frameworks.

## NIH syndrome

The modern Rails ecosystem has a very good answer to Not Invented Here syndrome, allowing you to use components from a wide variety of sources without worry.

### Open Source

The foundation of our ecosystems answer to NIH syndrome is that the vast majority of the ecosystem is open source.  Being open source means that you can inspect any code you use for issues.   If you run into a bug or missing feature or design flaw, you can either fix it yourself or pay somebody to fix it for you if the original vendor is not responsive.

### GitHub

The vast majority of Ruby/Rails/Hobo plugins are available on GitHub, which makes them easy to discover, inspect and fork.   If you have to fix problems yourself, GitHub makes it easy to do that, and it also makes it easy for the world to use your fix, thus taking over its maintenance.

### Bundler

Bundler manages your project's dependencies in a way that's optimal for both multi-user development and for deployment.   You can depend on very general or very specific versions of a dependency, down to a specific git commit SHA, and easily switch to your own fork of the dependency.   NPM's package.json provides similar capabilities, but I find it much more awkward to use in a multi-developer settings.   I suspect it's the separation between Gemfile and Gemfile.lock that makes Bundler so much nicer.
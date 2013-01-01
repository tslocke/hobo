# What's a good development cycle?

e.g. As I was learning, I've found that it paid to do a 'hobo g
migration' pretty much anytime I'd changed a file. Eventually I've
worked out when I *should* do a "hobo g migration", but I wasn't doing
it enough to start with and that caused silly problems.

This is a big question, since there are lots of opinions on how 
best to do development. But here are some thoughts:

- work in small iterative loops, and test what you do at each stage
- get the guts of your data model working first, eg company has many 
people, each person has many tasks etc. 
- use the vanilla Hobo app framework to verify that you've got this core 
plumbing working, before starting on your custom pages and controllers
- migrations only need to happen when you change the data model 
(ie when you add/delete fields or indexes from files in the models folder)
- use the rails console if you want to interrogate the database while
running your app
- run your app in debug mode if you're struggling to work out what's 
happening in the dryml, controllers, or specifically if you want to 
understand what "this"is at any specific point.
- use Heroku or similar as a staging/test environment - this will 
force you to make sure your configuration, plugins etc are nailed down
- use Firefox with Firebug or similar when working on tweaks to styles, 
layout, ajax etc 

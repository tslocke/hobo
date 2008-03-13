[Back to contents](index.html)

# Overview

Hobo is a plugin for Ruby on Rails that brings a number of extensions, some small some large, to Rails application development. The common theme to these extensions is rapid development. Like Rails itself, Hobo encapsulates a number of opinions about web application development. The opinion that is most central to Hobo is this: we have found that  there is a great deal of similarity from one web application to the next. Much more similarity in fact, than is supported by today's frameworks. We would rather implement this stuff once. Of course this idea is common to all frameworks -- everything that Rails provides is there because many or all web applications will need it: database connectivity, session management, working with HTTP, etc. etc. The difference with Hobo is that we are trying to take this idea to a much higher level than is normally expected from a web framework. The ultimate goal is: don't program your application, just declare it.

Because Hobo might do a lot more than you have come to expect from a web framework, it can be difficult to get a handle on what Hobo actually *is*. For example, it seems that a lot of people see Hobo as the same kind of tool as something like Active Scaffold. It is not. The only way to really get an understanding of how Hobo can speed up your web application development, is to use it. But, to help you get started, here's a brief summary of the main features you'll find in Hobo.

 * Model layer extensions :: In a Hobo app, you typically add the declaration `hobo_model` to all of your models (although you don't have to). This gives your models a bunch of extra smarts:
 
   * Migration generator :: A hobo model has the declaration of the database fields *inside* the model source code. Using this information, Hobo can generate complete migrations for you, including the down migration. You can add, remove and rename fields and entire models, and Hobo will compare the state of the database with the state of your source-code and create a migration to bring the database up to date.
    
   * Rich field types :: When you declare your database field types in Hobo, you are not limited to the basic SQL types. Hobo extends the default set with richer types like HTML, Markdown and Email-address, and you can add your own. The view layer knows how to render these types properly, and the model layer knows how to validate them.
  
   * Defined scopes :: Hobo's `def_scope` feature combines the best of the various scope plugins out there (e.g. scope-out) and adds some extras of it's own. Active Record will feel incomplete without it!
  
   * Permission system :: Hobo uses a model-centric permission system. On each model you declare exactly which user is allowed to do what. The controller layer will only allow creates, updates and deletes which you have permitted. The view layer will also use this information in various ways, e.g. automatically removing fields from forms if you do not have permission to change them.
  
   * User model :: The concept of a user model is baked-in in Hobo. If you declare any model as a `hobo_user_model`, you'll automatically get all the database fields and methods to give you authentication (log-in), including 'remember me' functionality.
  
  
 * Controller layer :: In a similar manner to the model extensions, you will typically add the declaration `hobo_model_controller` to every controller in your Hobo app. The features this brings in can eliminate a great deal of controller layer programming.
 
   * Auto-actions :: Just declare `auto_actions :all` and you'll get default implementations of all the 'standard' controller methods: index, show, edit, create, update and destroy. You'll even get actions to handle collections that your model provides (e.g. `show_topics` and `new_topic` on a forum resource). These actions can be extensively customised.
  
   * Web-methods :: for the situation where REST just doesn't fit, Hobo makes it easy to expose model methods as RPC style web-methods, and the permission system allows you to control who can call them.
  
   * Data-filters and search :: Publish parameterized filtering and searching functionality in a snap.
  
   * Sub-sites :: Web apps often need different "sub sites" for different kinds of user, the typical example being the "admin" site. Just create a directory in app/controllers, and Hobo will set it all up for you.
  
   * Automatic routing :: If you want to stick with conventional REST-style routes, all the information needed to configure the routes can be found in your controllers. Hobo has an automatic router that inspects your controllers and does the job for you.
  
  
 * View layer :: The view layer is where Hobo really shines. In fact it was the experience of spending 80% of development time in the view layer that led to the creation of Hobo. The vast majority of the effort behind Hobo has gone into the DRYML template language.
 
   * DRYML :: A template language built around the idea of defining your own tags. While the idea of defining your own tags is not new, DRYML has a unique take. Defining tags is extremely simple and lightweight, and, more importantly, DRYML has a very powerful mechanism for the customising the output of a tag each time it is used. This gives a very powerful combination of high-level re-use along with "context-over-consistency" tweaks.
  
   * Ajax mechanism :: DRYML makes it very easy to dynamically update parts of your page. There's no need for separate partial files - just mark the part you want to update, and DRYML will automatically extract it. When used in conjunction with Hobo Rapid, Ajax becomes so easy it's often *less* work than a non-ajax approach.
  
   * Hobo Rapid :: Hobo Rapid is a combination of view helpers, DRYML tags, JavaScript and CSS that take rapid development to a whole new level. You could say that all the rest of Hobo exists in order to make Hobo Rapid possible. Rapid provides a wide range of features, from small things like creating links and form-controls, all the way up to entire pages (e.g. show pages, index pages, edit pages). Together, these  give you a working user-interface completely automatically, based on your models. The important point though, is that thanks to the customisation features in DRYML, this automatic user-interface can be customised incrementally until you've got exactly the interface that your individual app needs.
  
  
 * General features
 
   On top of these extensions to the three MVC layers, Hobo provides some bits and pieces that help tie it all together.
   
   * Generators :: Rather than generate 'normal' Rails classes and then upgrade them with Hobo features, Hobo provides custom generators that create source-code that's ready to work with Hobo.
  
   * Ruby extensions :: This is Hobo's answer to Active Support - a grab bag of useful Ruby extensions to make your coding a little easier.
  
Hopefully this overview gives you a feel for what Hobo is all about. There's nothing like trying it though, so move on to the Quick-Start Guide and have a go!

Next: [Getting Started](2-getting-started.html)
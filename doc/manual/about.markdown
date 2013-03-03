About Hobo
{.document-title}

Hobo is a plugin for Ruby on Rails that brings a number of extensions&#8212;some small some large&#8212;to Rails application development. The common theme to these extensions is rapid development.

Like Rails itself, Hobo encapsulates a number of opinions about web application development. The opinion that is most central to Hobo is this: we have found that there is a great deal of similarity from one web application to the next. Much more similarity in fact, than is supported by today&#8217;s frameworks. We would rather implement this stuff once.

Of course this approach is common to all frameworks&#8212;everything that Rails provides is there because many or all web applications will need it: database connectivity, session management, working with HTTP, etc. etc. The difference with Hobo is that we are trying to take this idea to a much higher level than is normally expected from a web framework. The ultimate goal is: don&#8217;t program your application, just declare it.

Because Hobo might do a lot more than you have come to expect from a web framework, it can be difficult to get a handle on what Hobo actually <em>is</em>. For example, it seems that a lot of people see Hobo as the same kind of tool as something like Active Scaffold. It is not. The only way to really get an understanding of how Hobo can speed up your web application development is to use it. But to help you get started, here&#8217;s a brief summary of the main features you&#8217;ll find in Hobo.

### Model layer extensions

In a Hobo app, you typically add the declaration <code>hobo_model</code> to all of your models (although you don&#8217;t have to). This gives your models a bunch of extra smarts:

* [Lifecycles](/manual/lifecycles) :: REST is fine and dandy, but real applications need more than that.   Define a state machine on a model and Hobo will add support for it in your controllers and views as well.

* [Migration generator](/manual/hobo_fields/migration_generator) :: A hobo model has the declaration of the database fields <em>inside</em> the model source code. Using this information, Hobo can generate complete migrations for you, including the down migration. You can freely add, remove and rename fields and entire models. Hobo will compare the state of the database with the state of your source-code and create a migration to bring the database up to date.

* [Rich field types](/manual/hobo_fields/rich_types) :: When you declare your field types in Hobo, you are not limited to the basic SQL types. Hobo extends the default set with richer types like <em>HTML</em>, <em>markdown</em> and <em>email-address</em>. You can also add your own. The view layer knows how to render these types properly, and the model layer knows how to validate them.

* [Permission system](/manual/permissions) :: Hobo uses a model-centric permission system. On each model you declare exactly which user is allowed to do what. The controller layer will only allow creates, updates and deletes which you have permitted. The view layer will also use this information in various ways, e.g. automatically removing fields from forms if you do not have permission to change them.

* [User model](/manual/users_and_authentication) :: The concept of a user model is baked-in in Hobo. If you declare any model as a <code>hobo_user_model</code>, you&#8217;ll automatically get all the database fields and methods to give you authentication (log-in), including &#8216;remember me&#8217; functionality.

### Controller layer

In a similar manner to the model extensions, you will typically add the declaration <code>hobo_model_controller</code> to every controller in your Hobo app. The features this brings in can eliminate a great deal of controller layer programming.

* [Auto-actions](/manual/controllers#selecting_the_automatic_actions) :: Just declare <code>auto_actions :all</code> and you&#8217;ll get default implementations of all the &#8216;standard&#8217; controller methods: index, show, new, edit, create, update and destroy. You&#8217;ll even get actions to handle collections that your model provides (e.g. <code>topics</code> and <code>new_topic</code> on a forum resource). These actions can be extensively customised.

* Filtering, searching and sorting :: Publish parameterized filtering and searching functionality in a snap.

* [Sub-sites](/tutorials/subsite) :: Web apps often need different &#8220;sub sites&#8221; for different kinds of user, the typical example being the &#8220;admin&#8221; site. Just create a directory in app/controllers, and Hobo will set it all up for you.

* [Automatic routing](/manual/controllers) :: If you want to stick with conventional REST-style and state machine routes, all the information needed to configure the routes can be found in your controllers. Hobo has an automatic router that inspects your controllers and does the job for you.

### View layer

The view layer is where the real Hobo magic lies. In fact it was the experience of spending 80% of development time in the view layer that led to the creation of Hobo. The vast majority of the effort behind Hobo has gone into the DRYML template language.

* [DRYML](/manual/dryml-guide) :: A tag based template language built. While the idea of defining your own tags is not new, DRYML has a unique take. Defining tags is extremely simple and lightweight, and, more importantly, DRYML has a very powerful mechanism for the customising the output of a tag each time it is used. This gives a very powerful combination of high-level re-use along with &#8220;context-over-consistency&#8221; tweaks. DRYML also features an <em>implict context</em> that makes you&#8217;re view code poetically brief.

* [Ajax mechanism](/manual/ajax) :: DRYML makes it very easy to dynamically update parts of your page. There&#8217;s no need for separate partial files - just mark the part you want to update, and DRYML will automatically extract it. When used in conjunction with Hobo Rapid, Ajax becomes so easy it&#8217;s often <em>less</em> work than a non-ajax approach.

* [Hobo Rapid](/api_plugins/hobo_rapid) :: Hobo Rapid is a combination of view helpers, DRYML tags, JavaScript and CSS that take rapid development to a whole new level. You could say that all the rest of Hobo exists in order to make Hobo Rapid possible. Rapid provides a wide range of features, from small things like creating links and form-controls, all the way up to entire pages (e.g. show pages, index pages, edit pages&#8230;). Together, these give you a working user-interface completely automatically, based on your models. The important point though, is that thanks to the customisation features in DRYML, this automatic user-interface can be customised incrementally until you&#8217;ve got exactly the interface that your individual app needs.

### General features

On top of these extensions to the three MVC layers, Hobo provides some bits and pieces that help tie it all together.

* [Generators](/manual/generators) :: Rather than generate &#8216;normal&#8217; Rails classes and then upgrade them with Hobo features, Hobo provides custom generators that create source-code that&#8217;s ready to work with Hobo.

* [Ruby extensions](/manual/hobo_support) :: Hobo&#8217;s answer to Active Support - a grab bag of useful Ruby extensions to make your coding a little easier.

Hopefully this overview gives you a feel for what Hobo is all about. There&#8217;s nothing like trying it though, so move on to the <a href='/tutorials/two-minutes'>two minute Hobo app</a> or one of the other <a href='/tutorials/recipes'>tutorials</a>.

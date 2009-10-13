# Welcome to the Hobo-i18n
This is a Hobo fork of git://github.com/tablatom/hobo.git, merged with soey's great I18n extensions. After that I have maintained it myself.


## Main Features
The i18n support is granted via a translation tag &lt;ht&gt; for hobo's dryml-files which actually uses the ht() helper method (lib/hobo/hobo_helper.rb). ht() uses the RoR 2.2+ I18n translate methods internally.


### View-code (dryml): &lt;ht&gt;&lt;/ht&gt;

Usage
<code>

    <ht key="foo.bar"/> 
    # -> ht("foo.bar", :default=>:"hobo.bar")
    
    <ht key="foo.bar">Fallback</ht> 
    # -> ht("foo.bar", :default=>[:"hobo.bar", "Fallback"])

</code>

 * The main idea of the translate tag is to replace the wrapped content with the translated string identified by the key. By using the content of the key as a default value its possible to leave the templates mostly as they are. Just wrap the strings that shall be translated with the &lt;ht&gt; tag.

 * If you don't provide a translation file/keys everything should keep as is.

 * If you provide the matching keys, the inner content will be replaced by the translated string.

The translation key uses the ht method - as the above usage sample shows. Which brings us to the next section.
 

### Ruby-helper: ht(key, options={})
A wrapper around I18n.translate, which adds some conventions for easier translation of hobo content

 1. Assumes the *first* part of the key to be a *model* name (e.g.: *users*.index.title -> *user*)

 2. Tries to translate the *model* by lookup for: (e.g.: *user*-> activerecord.models.*user*). The key shown in this sample is as you can see the same as RoR i18n uses.

 3. If 1. and 2. fails then a fallback replaces the first part of the key with "hobo" and uses the translated *model* name as an additional attribute. This allows us to have default translations for hobo where models or translations are yet not provided (e.g.: hobo.index.title = "{{model}} Index") 

We assume that we have nothing custom in the locale file, but we do have the hobo-i18n standard key, <code>hobo.index.title: "{{model}} Index"</code> in there.

Here's what happens when we try to do the following ht()-lookup:

<code>
ht("users.index.title", :default=>"Index of Users")
</code>
 
 1. ht will try to find the users.index.title key in the locale-yml-file. 

 2. Since it will yield no hits it will set model=>"user", 

 3. It will then replace the first part of the key from "**users**.index.title" to "**hobo**.index.title".

 4. It will then run a new i18n-translation attempt at the "hobo.index.title" key, and will pass on the model=>"user" for interpolation in the result.

All standard translations are scoped with hobo (see below). If you want specific translations for specific models, just copy/add another scope with the name of the model. For example you can have a specific heading for a "customer" index page by giving the following translation key:
<pre>
<code>
...
  customer:
    page:
      index:
        heading: "My special customer index heading"
...
</code>
</pre>
For more samples search the code for ht() or &lt;ht&gt;&lt;/ht&gt; sections.


### View-hints
This system will look up the view-hints directly from the keys you add (i.e. in app.*.yml). Sample section from a typical app.en.yml file:
<pre>
<code>
en:
  users:
    hints:
      name: "This is the name shown to the users in the application. It should contain the user's full name."
      email_address: "The email-address here is used as a user-id as well as a means of communicating with the user via email. Make sure the user has allowed mail from the host of this application." 
</code>
</pre>

### Locale files [http://github.com/Spiralis/hobo-i18n-locales](http://github.com/Spiralis/hobo-i18n-locales)

 1. A separate git-repository has been set up to contain the locale-files for different languages. There is a specific hobo.&lt;locale&gt;.yml for each locale. These are standard hobo keys. 

 2. In addition to this you probably also have a rails.&lt;locale&gt;.yml file to handle Rails-i18n keys (check Sven Fuchs [rails-i18n-repository](http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/) for your locales). 

 3. Finally - you should have an app.&lt;locale&gt;.yml files where you keep your customizations. You might have other locale-files and you may also use other conventions. It's all up to you. 


### Locale tools
  * harvester (TO-DO)

    Typical locale key-harvesters will fail in Hobo projects. They normally search through the files looking for constant keys. Hobo-translation-keys however, often need to be  evaluated run-time. Instead the harvester should be built into the ht method. The harvester would each time a translation-lookup is done check the key for existence (and log the passed interpolation values). Some heuristics could be applied on the key itself to better understand where the key should be saved. If not to be saved in the hobo.&lt;locale&gt;.yml-file then it will add it to the app.&lt;current-locale&gt;.yml-file. 

  * translation (TO-DO)

    Changing the locale-files by hand is the only way at the moment. However. It shouldn't be too difficult to add a hobo-web-interface for the keys, with focus on the app.*.yml files. It should be possible to show keys in english plus at least one other language at the same time. Next to this, statistics should be available, also showing the interpolation-names used when called. 


## Issues

 - There are more conventions added by rails. Mainly the [lazy lookup/automatic skin scoping](http://guides.rubyonrails.org/i18n.html) (section 4.1.4). This would lead to other scoping conventions. Maybe this should be considered later.

 - Automatic inflections are no real use. (Just stay with the english defaults in most cases ;)) or use specific translation keys.

 - No tests yet

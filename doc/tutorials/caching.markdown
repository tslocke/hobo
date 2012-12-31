In the last couple of years, it has become accepted wisdom in some circles that to build a fast, responsive web application you need to use a client-side Javascript framework such as Ember, AngularJS or one of their myriad competitors.

But earlier this year, dhh challenged this accepted wisdom with a blog post: [How Basecamp Next got to be so damn fast without using much client-side UI](http://37signals.com/svn/posts/3112-how-basecamp-next-got-to-be-so-damn-fast-without-using-much-client-side-ui)

In it, dhh outlined two very powerful techniques that can be used to massively speed up a Rails application: pjax and stacker.

The original pjax implementation worked very similarly to Hobo's ajax part mechanism.  In Hobo 2.0 we added supported for a [push-state option](http://cookbook.hobocentral.net/manual/changes20#pushstate) for part ajax which will allow you to use the pjax technique with ajax parts to speed up a larger portion of your web site.

DHH and the Rails team have since written a gem called [turbolinks](https://github.com/rails/turbolinks).  turbolinks works on full pages rather than page fragments so can be slightly slower than Hobo push-state, but it is much easier to use and can be easily applied to your entire application.  Hobo 2.0.0.pre7 is compatible with turbolinks, and I highly recommend its use.

The other technique dhh called "Stacker", which uses a technique sometimes called "Russian Doll Caching".   This is a tool internal to 37 signals, which has not been released as open source software.  Some of its functionality has been extracted into [cache_digests](https://github.com/rails/cache_digests), but this still requires much manual effort to apply to your application.

But due to the additional information available to Hobo applications, the Russian doll technique is much easier to use with Hobo.   Hobo 2.0 includes 3 new caching tags that make the use of Rails caching techniques much easier.

This tutorial demonstrates the use of these three caching tags.

The sample application that we're using for this demo is very simple.  Besides the standard User model, we've added a Widget model with two columns, name and quantity.  It's so simple that caching really isn't going to provide a huge benefit, but let's assume that the quantity column is actually a rather expensive computed value that would greatly benefit from caching.

We're going to use the Rails default MemoryStore for caching.   This cache works great for development, but you'll probably want to choose a different cache store for your production server.  There are a large number of stores available, all with different trade offs.   Choice of cache store is outside the scope of this article.

For the purposes of our demo, we're going to cache the widget index page since it displays many different models in one page.   Here's what it looks like:

SCREENSHOT

and here's the view code [app/views/widgets/index.dryml](https://github.com/Hobo/hobo_caching_demo/blob/master/app/views/widgets/index.dryml):

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/views/widgets/index.dryml"> </script>

First, let's use the simplest hobo cache tag, `<hobo-cache>`.   `<hobo-cache>` does not support hierarchical, russian doll type caching, and is comparable to standard Rails fragment caching techniques.

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/views/widgets/cached.dryml"> </script>

To use the `<hobo-cache>` tag, you need to specify all of the dependencies of the fragment that you are caching.   Normally, there are four types of dependencies: context, current_user, query-params and route.

The *context* is the data that's being displayed by the fragment.  `<hobo-cache>` provides no helpers for the context, so we store an appropriate signature of the context in an arbitrary attribute.   `widgets=`, in this case.   `widgets` doesn't have any special meaning to `<hobo-cache>`; extra attributes are used as cache keys.

The easiest context signature is to serialize the entire context and its children.  This is usually overkill.  cache_digests uses a hash (aka digest) of the data.  This is often the most appropriate mechanism if you are using a NoSQL distributed database.  However, we're using an SQL database with timestamps.   The timestamp is updated whenever the model changes, so it is a sufficient signature along with the model id:  `widgets="&this.map{|w| [w.id, w.updated_at]}"`

Besides the data itself, the state of the *user* often affects the display of the fragment.  If so, we need to capture this dependency.  We could use a signature of `current_user`, but that's typically overkill and would mean each user would require separate caches, exploding storage requirements and negating much of the benefit of caching in the first place.  Luckily that's rarely necessary.  Many hobo applications have three types of users: guests, administrators and normal users.   We can capture this with `guest="&current_user.guest?" admin="&current_user.administrator?"`.   Our demo displays the same data no matter what kind of user is logged in.

The request's query parameters often affect the display of the fragment.  In our case, the page processes the search, sort and page parameters.  `<hobo-cache>` has a shorthand for query parameter dependencies:  `query-params="search,sort,page"`.  This is essentially the same as `search="&params[:search]" sort="&params[:sort]" page="&params[:page]"`.

The final dependency that needs to be captured is the fragment's *route*.  This can be thought of as the fragment's identifier.  This defaults to the page route, which is sufficient for our demo because the fragment is only used on a single page and there is only a single fragment on the page.

If there is more than one fragment on the page, we'd have to add something to distinguish between the two.   By convention we use the `suffix` attribute.   For example if we had two fragments on the page, we could add `suffix='top'` to one and `suffix='bottom'` to the other.

If the fragment is used on more than one page, we'd probably want to adjust it's routing so that the different pages can the cache when it's appropriate.  To adjust the route, use the `route-on` attribute.   For more information on `route-on`, see the `<hobo-cache>` documentation.  We'll also have a route-on example later in this tutorial.

The cache is functional, but it has to be completely rebuild any time everything changes.  So now we'll introduce the concept of hierarchical caches, aka russian doll caching.  The idea is that we will cache each line in the table individually as well as caching the parent table.  If a single line needs rebuilding, only that line is rebuilt.   The table is then rebuilt from the line caches.

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/views/widgets/simple_russian.dryml"> </script>

Note that we're taking advantage of Hobo's nested parameters here.  The `actions-view` parameter is inside of the `tr` parameter, so it is included in the `widget` cache.  Refer to the [DRYML guide](/manual/dryml-guide) if you need more information on DRYML and nested parameters.

Note that now that we have more than one cache tag on this page we've added a `suffix` cache key to ensure that there are no cache collisions.

Here we are still using the `<hobo-cache>` tag so you have to manually ensure that the cache keys passed to the outer cache tag are a superset of the cache keys passed to the inner cache tag.   That's quite easy for this simple example, but on a more complex website this violates the principle of Don't Repeat Yourself.  Dependency information should only be specified in one place.

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/views/widgets/simple_russian.dryml"> </script>

We've made two major changes for nested.dryml.   We've switched from `<hobo-cache>` to `<nested-cache>`, and we've split out the table row into it's own tag.

Creating a widget row tag was not necessary, but it is a pattern typically seen in larger applications.  Sensible partitioning and encapsulation of your views is one of the biggest advantages that DRYML brings to your application, let's take advantage of it.

Let's take a closer look at the changes we made when switching from `<hobo-cache>` to `<nested-cache>`.  Taking a look at the inner cache, there are two changes: we're now using the `methods` and `route-on` attributes rather than using our own cache keys.

`methods` is the attribute that enables hierarchical dependency tracking.  This is a comma delimited list of methods that may be called on the current context.  The results of these calls become cache keys on the current cache as well as any parent caches.   Only cache keys specified via `methods` and/or `query-params` are hierarchical; all others must be propagated manually to parent caches, if that is necessary.

We've also used the `route-on` parameter.  We've separated out the widget row into it's own tag, it may be reused on other ages.  By explicitly specifying the cache key path via route-on, widget row caches may be shared between different pages.

On the parent cache, we no longer need to specify cache keys for our children elements.   So how come we have `widgets="&this.map &:id"` as a cache key?  Without it, our cache would be properly invalidated if any of the child widgets change or are deleted.  But if a new widget is added, none of the existing child widgets will be invalidated.  Only the outer cache is invalid.  With `<nested-cache>` we don't have to worry about the dependencies of our children, but we do have to ensure that the correct set of children are included.

Hobo 2.0 includes a third caching tag, `<swept-cache>`.  The fundamental difference between `<nested-cache>` and `<swept-cache>` is that the validity of `<nested-cache>` is checked every time it is used, whereas `<swept-cache>`'s are invalidated when their contents change and are not checked when they are viewed.

`<swept-cache>` works by recording the dependencies for a fragment cache when the cache is first created.  `<swept-cache>` supports three different types of identities: a unique symbol, objects that have a `typed_id` method, or both.

All Hobo models contain the `typed_id` method, which generates a string unique to that model, so typically they are what are used as dependencies for `<swept-cache>`.   If you do not explicitly specify the dependencies, the current context (AKA this) is used.

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/views/widgets/swept.dryml"> </script>

The row cache has the default dependency, the current context, the widget.

The parent table cache almost works without any additional dependencies.  The dependencies of all children automatically become dependencies of the parent, so when a child is invalidated the parent is also invalidated.

But in our case, a change to a child may not just invalidate the page that it's displayed on.   If the change affects the sort order all of the pages may change.  Therefore we've created a symbol that we can use in our sweepers when any widget has changed.

Rails includes Sweepers which allow both model and controller hooks in convenient locations to allow you to invalidate caches.   Hobo adds an additional helper `expire_swept_caches_for` which invalidates all appropriate `<swept-cache>`'s.

<script src="http://gist-it.appspot.com/github/Hobo/hobo_caching_demo/raw/master/app/sweepers/widget_sweeper.rb"> </script>

`expire_swept_caches_for(widget)` expires the caches for the widget row cache and for any table caches that contain the row.   `expire_swept_caches_for(:all_widgets)` then expires all table caches.  So our use of fancy hierarchical dependency tracking is not helping.   Luckily this is something that's generally more useful on real websites.

### Deciding whether to use a swept cache or an LRU cache

Our first few examples never expire items from the cache.   Therefore some mechanism is needed to ensure that your cache does not grow too large.   Our first examples do not have any sort of stability requirements: if a cache doesn't exist it is regenerated, and because we're using `updated_at` in our cache keys, we will never use stale caches.  Therefore you can arbitrarily eject any data from the cache at any time.  In most cases, you would set up your cache in LRU mode to evict the least recently used data from your cache.   This is the default configuration for many of Rails' cache stores.

The `<swept-cache>` tag stores dependency information in the cache so it does have a bunch of stability requirements that are listed in the documentation for `<swept-cache>`.

But `<swept-cache>` can be significantly faster in some workloads, when reads dramatically outnumber writes.  In our example, when the cache is hit we do not have to load any widgets from the database.

Further discussion of the pros and cons of a swept versus auto-expiring cache approach is outside the scope of this document.  It does appear that the swept approach is going out of fashion these days because it doesn't scale to hundreds of servers as easily as an auto-expiring cache does.   However, that sort of scale is not a concern for the vast majority of web sites.

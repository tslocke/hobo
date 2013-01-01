# How slow is Hobo?

Hobo in development mode is much slower than vanilla Rails, however in
production mode the speed should be comparable.

Optimizing a Hobo application is very similar to optimizing a Rails
application, so many of the techniques and online resources which
apply to Rails apps may help for Hobo apps too.

There are some things you can turn on that can significantly speed up
your Hobo application:

* make sure you are running in production mode
* [bottom load javascript](http://cookbook.hobocentral.net/manual/changes20#bottomloading_javascript)
* [explicit push-state](http://cookbook-1.4.hobocentral.net/manual/changes20#pushstate) or [implicit push-state](https://github.com/rails/turbolinks)
* turning off permission checks by passing `force` to `<view>`, `ignore` to `<input>` and `force_all` to field lists.

There are two major steps to optimizing a Rails application:

+ optimizing database access
+ caching

*Optimizing database access* is slightly more difficult in Hobo than in
Rails because database access in Hobo is usually implicit. To
optimize, we add an initial efficient explicit access.   For example:

    def show
      self.this = Foo.find(params[:id]).includes(:bar, :bat)
      hobo_show
    end

Make sure that your relationships have the :inverse_of option set on
both ends or this technique will make things worse rather than better.

Also ensure that every column that you are sorting or searching on is
indexed in your database.

*Caching* a Hobo application is much easier than caching a Rails
application. Rails caching is described in the [Caching with Rails
Guide](http://guides.rubyonrails.org/caching_with_rails.html). Page
caching and action caching are identical in both Hobo & vanilla Rails,
but [Hobo adds several tags to make fragment caching much
easier](http://cookbook-1.4.hobocentral.net/api_taglibs/cache).

There's a [tutorial describing the Hobo caching tags](/tutorials/caching)

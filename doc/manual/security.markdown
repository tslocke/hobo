There have been a spate of security patches to Ruby on Rails lately, which has understandably raised concerns about the wisdom in choosing a Ruby on Rails based framework for your application.

The flexibility of Ruby on Rails does make it harder to secure than some other web frameworks.  Ruby on Rails is designed to "work out of the box", so it may have more vectors for communications open than you would expect, and the one you do expect are perhaps more flexible than you need.

Being difficult to secure does not mean impossible to secure.  The recent spate of security fixes for old versions of Ruby on Rails indicate that there is a concerted, active effort to find and patch these holes.

If you were to use a lighter framework you would end up designing more of the interfaces yourself.  This is much easier to secure than a general framework, but it means you must do it yourself rather than enlisting the help of a large team of experts.

Hobo itself does not add any additional communications mechanisms to Rails.  It does add one additional layer of security, <a href="/manual/permissions">the permissions framework</a>.

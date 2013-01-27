--- 
wordpress_id: 258
author_login: bryanlarsen
layout: post
comments: 
- author: Owen
  date: Wed Nov 18 02:19:23 +0000 2009
  id: 51760
  content: |
    <p>Looking good!</p>
    
    <p>-Owen</p>

  date_gmt: Wed Nov 18 02:19:23 +0000 2009
  author_email: odall@barquin.com
  author_url: http://www.barquin.com
- author: Betelgeuse
  date: Wed Nov 18 14:43:09 +0000 2009
  id: 51761
  content: |
    <p>The link to github is weird. The latest entry there is from 2008-09-03.</p>

  date_gmt: Wed Nov 18 14:43:09 +0000 2009
  author_email: ""
  author_url: ""
- author: Bryan Larsen
  date: Wed Nov 18 14:46:47 +0000 2009
  id: 51762
  content: |
    <p>Thanks -- the github link should be fixed now.  Last time I forgot to push the tag.   This time I linked to my fork rather than Tom's.   Hopefully I'll get it right for 1.0... :)</p>

  date_gmt: Wed Nov 18 14:46:47 +0000 2009
  author_email: bryan@larsen.st
  author_url: http://bryan.larsen.st
- author: Owen
  date: Wed Nov 18 20:08:49 +0000 2009
  id: 51763
  content: |
    <p>I started testing this with Oracle at about 5 am my time.  So far so good with the index naming overrides Matt included to deal with Oracles lame 30 character limit!</p>
    
    <p>For example:</p>
    
    <p>class TaskAssignment < ActiveRecord::Base</p>
    
    <p>hobo_model # Don't put anything above this</p>
    
    <p>fields do
        timestamps
      end</p>
    
    <p>belongs<em>to :user, :index => 'user</em>join<em>index'
      belongs</em>to :task, :index => 'task<em>join</em>index'</p>
    
    <p>end</p>

  date_gmt: Wed Nov 18 20:08:49 +0000 2009
  author_email: ""
  author_url: ""
- author: Brandon
  date: Tue Dec 01 15:37:55 +0000 2009
  id: 51775
  content: |
    <p>Hey, are you still on target for releasing 1.0 RC today?  (I've been looking forward to this for a long time!)</p>

  date_gmt: Tue Dec 01 15:37:55 +0000 2009
  author_email: brandon.zylstra@gmail.com
  author_url: ""
- author: Brandon
  date: Tue Dec 01 15:44:20 +0000 2009
  id: 51776
  content: |
    <p>BTW, (almost?) every time I submit a comment, I seem to get something like this (although the comment is received and appears if I go back and refresh the page):</p>
    
    <p>Internal Server Error</p>
    
    <p>The server encountered an internal error or misconfiguration and was unable to complete your request.</p>
    
    <p>Please contact the server administrator, bryan@XXXXXXXXXX and inform them of the time the error occurred, and anything you might have done that may have caused the error.</p>
    
    <p>More information about this error may be available in the server error log.
    Apache/2.2.8 (Ubuntu) Phusion_Passenger/2.2.2 Server at hobocentral.net Port 80</p>

  date_gmt: Tue Dec 01 15:44:20 +0000 2009
  author_email: brandon.zylstra@gmail.com
  author_url: ""
- author: ""
  date: Tue Dec 01 15:49:44 +0000 2009
  id: 51777
  content: |
    <p>I'll look at the wordpress error after we do the release today.  :)</p>

  date_gmt: Tue Dec 01 15:49:44 +0000 2009
  author_email: ""
  author_url: ""
author: Bryan Larsen
title: Hobo 0.9.0 released
published: true
tags: []

date: 2009-11-17 19:12:55 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?p=258
author_url: http://bryan.larsen.st
status: publish
---
We've just released version 0.9.0 of Hobo.&nbsp; It is available on  [gemcutter](http://gemcutter.org/) now, and should be on  [rubyforge](http://rubyforge.org/) within 24 hours.

We're now entering a feature freeze.&nbsp; We plan on releasing a 1.0 release  candidate on December 1st.&nbsp; After that point, we will only be fixing  critical bugs and documentation.&nbsp; At this point, we do not consider any  of our [extant  bugs](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/bins/8323)  to be critical.&nbsp;&nbsp; We'll fix as many of them as we can before December  1st.&nbsp; If any of them are important to you, please speak up so we can  prioritize appropriately.

Major enhancements:
 
  - Internationalization! Through the hard work of soey and Spiralis,
    we now have internationalization support in Hobo. The manual
    page is on the
    [cookbook](http://cookbook.hobocentral.net/manual/i18n). Locales
    are available on
    [github](http://github.com/Spiralis/hobo-i18n-locales).
 
  - Index generation: Matt Jones' automatic index generation code has
    been merged. Migrations performed with 0.9.0 will now include appropriate indices.  The default Rails index names are very long, so this
    is unlikely to work well on Oracle, which has a 30 character
    limit. Testing against Postgres, Oracle, SQL Server and JDBC has
    been extremely limited. To generate indices run `script/generate hobo_migration`.
 
  - New projects now have a summary page on /front/summary that
    provides application information to the administrator. Current
    projects may add this action by running the
    `hobo_front_controller` generator.
 
  - STI derived classes can add additional fields to their parent
    class with the fields block. Note that the "can't generate a
    migration for STI base and derived classes all at once" issue
    still applies. In general, STI handling should now work much
    better.
 
  - [Bug 464](https://hobo.lighthouseapp.com/projects/8324/tickets/464-transition-buttons-should-have-a-option-to-link-to-forms-instead-for-transitions-that-take-parameters)
    The transition-buttons tag now generates buttons that link to the
    transition page for transitions that require parameters.
 
  - [Bug 532](https://hobo.lighthouseapp.com/projects/8324/tickets/532)
    In previous versions, you had to add the new HTML5 tags to
    `RAILS_ROOT/config/dryml_static_tags.txt`. This version whitelists
    all HTML5 tags except for aside, section, header and footer, which
    conflict with existing Rapid tags.
 
Major bug fixes:
 
 - [Bug 530](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/530)
   is a critical bug for invite-only projects. To incorporate the
   fix, you must rerun your generators or follow the instructions in
   the [commit](http://github.com/tablatom/hobo/commit/17247eac8a78f8b36dcc3b9684a3e4ec8da32a23)
 
 - [Bug
   480](https://hobo.lighthouseapp.com/projects/8324/tickets/480-find_owner_and_association-method-for-has_many-associations)
   Owner actions now work with has\_many associations
 
 - [Bug 516](https://hobo.lighthouseapp.com/projects/8324/tickets/516-association-name-as-parameter-in-lifecycle-step-almost-works)
   Specifying a belongs\_to association as a lifecycle param works; it appears as a select-one on the generated page.
 
 - [Bug 515](https://hobo.lighthouseapp.com/projects/8324/tickets/515-virtual-boolean-field-uninitialized-constant-hobobooleancolumn_type)
   Virtual :boolean fields declared with attr\_accessor now work
 
 - [Bug 484](https://hobo.lighthouseapp.com/projects/8324/tickets/484-transition-actions-with-key-fail-if-model-isnt-visible-to-guests)
   Transition actions that require a key no longer check if the model is visible to Guest
 
 - [Bug 485](https://hobo.lighthouseapp.com/projects/8324/tickets/485-make-lifecycles-on-sti-subclasses-behave)
   Lifecycle support on STI models works now. Note that derived classes DO NOT inherit any of the parent lifecycle implementation.
 
 - [Bug 387](https://hobo.lighthouseapp.com/projects/8324/tickets/387-inheritance-sti-models-name-not-propagating)
   STI derived classes now inherit settings like name\_attribute correctly.
 
 - [Bug 533](https://hobo.lighthouseapp.com/projects/8324/tickets/533-remove-id-from-hidden-field-for-check-box)
   The hidden field generated with a checkbox input shouldn't have an ID.
 
 - [Bug 526](https://hobo.lighthouseapp.com/projects/8324/tickets/526-routing-error-does-not-render-not-found-page)
   Routing errors now render not-found-page, rather than the default Rails routing error message.
 
Minor Enhancements:
 
 - Aside collections now have a new-link at the bottom (inside the
   preview-with-more)
   [#421](https://hobo.lighthouseapp.com/projects/8324/tickets/421-auto_actions_for-doesnt-create-add-button-in-sidebar)
 
 - the manual now includes a Generators section, and a subsite
   tutorial has been added.
 
 - [Bug
   386](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/386)
   and [Bug
   501](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/501)
   have been fixed, reducing the number of extraneous migrations that
   the hobo\_migration generator creates. These are actually Rails
   and/or database bugs we're working around. For instance, MySQL
   does not allow default values for text columns, so Rails silently
   ignores them. SQLite does not allow scale or precision settings on
   decimal fields. These types of bugs are good reasons why you
   should use the same type of database for development, testing and
   production.
 
 - A new view\_hint, `inline_booleans`, controls whether boolean attributes are displayed in the header (default behavior
   of Rapid show pages) or inline with the rest of the field-list. You can either pass a list of field names, or 'true'
   (without quotes) to make all booleans inline.
 
 - hobo\_show now accepts a model instance as a first parameter. This restores symmetry with the other hobo\_\* actions.
 
 - on Rails 2.3 and above, routes will be generated with the optional .:format suffix, and the formatted\_\* routes are skipped.
 
 - non-required fields that are marked :unique will now allow nil
   values.
 
Minor Bug Fixes
 
 - [Bug 540](https://hobo.lighthouseapp.com/projects/8324-hobo/tickets/540)
   Hobo::Permissions::Associations::HasManyThroughAssociations#create!
   did not save as the "!" implied.
 
See the [github log](http://github.com/tablatom/hobo/commits/v0.9.0)
 

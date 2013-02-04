--- 
layout: post
author: Bryan Larsen
title: "2.0.0.pre8: final prerelease"
date: 2013-02-04 12:00:00 +00:00
author_email: bryan@larsen.st
---
I'm proud to announce the release of Hobo 2.0.0.pre8.  We're planning on releasing this as 2.0.0 final in a week or so if no significant issues are found, so please test this release against your applications.

This release has been tested against Rails 3.2.11 on Ruby 1.9.3-p374, Ruby 1.8.7-p378 and JRuby 1.7.2.

## Changes

The vast majority of updates to Hobo for 2.0.0.pre8 were to the documentation.

- The default theme has been changed to Bootstrap

- MarkdownString will now use Kramdown, RDiscount or Maruku in preference to Bluecloth if these are available.

## Minor Changes

- `<sortable-input-many>` and `<sortable-collection>` have been moved to the hobo_jquery_ui gem

- fix for `recognize_page_path` when used for non-GET requests

- fix for AJAX response when no part is specified

- `<view>` has gained a force attribute

- ILIKE is now used for automatic scopes on Postgres

- `hobo_login` now respects the return code of its block

- the user class now works without a lifecycle

- fixes for non-empty relative url root

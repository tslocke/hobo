--- 
wordpress_id: 11
author_login: admin
layout: page
comments: 
- author: "Hobo: A Rapid Web App Builder for Rails"
  date: Fri Jan 05 08:53:19 +0000 2007
  id: 60
  content: |
    <p>[...] Hobo can be installed as a gem so you can create new applications from scratch with the hobo command line tool, or as a plugin so you can add Hobo features to existing applications. Learn more in the installation guide. Hobo also includes a templating system and mark up language called DRYML (Don't Repeat Yourself Markup Language) that allows you to include things using custom defined HTML tags, rather than <%= %> blocks. There's quite a lot to Hobo, so you'll want to go through its comprehensive official site and watch the Hobo screencast to get a real feel for it where a classified ads app is created within minutes. [...]</p>

  date_gmt: Fri Jan 05 08:53:19 +0000 2007
  author_email: ""
  author_url: http://www.rubyinside.com/hobo-a-rapid-web-app-builder-for-rails-350.html
- author: "Rubynaut : Rails Application builders"
  date: Mon Mar 26 14:04:06 +0000 2007
  id: 1063
  content: |
    <p>[...] hobo quick start  The most &#8220;alive&#8221; and completed builder. It provides: [...]</p>

  date_gmt: Mon Mar 26 14:04:06 +0000 2007
  author_email: ""
  author_url: http://www.rubynaut.net/articles/2007/03/26/rails-application-builders
- author: Ruby Brasil - &raquo; Acelere o desenvolvimento em Rails com o Hobo
  date: Tue Mar 27 20:22:35 +0000 2007
  id: 1091
  content: |
    <p>[...] Para estar com o Hobo rodando em poucos minutos, veja o tutorial com alguns screencasts e visite o site do projeto.    Tags: Artigos O que voc&Atilde;&ordf; achou deste artigo?  (N&Atilde;&pound;o h&Atilde;&iexcl; votos) &nbsp;Loading ... [...]</p>

  date_gmt: Tue Mar 27 20:22:35 +0000 2007
  author_email: ""
  author_url: http://ruby-br.org/?p=168
author: Tom
title: Get Started
published: true
tags: []

date: 2006-11-13 14:49:56 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobotek.net/blog/getting-started/
author_url: http://www.hobocentral.net
status: publish
---
*Hobo is beta software - version 0.8.3 Although Hobo is in active use in production applications, please be aware that if you choose to deploy a Hobo/Rails application on the Internet you do so at your own risk.*

*Also note that at this stage we reserve the right to make breaking changes to the API.*

## Getting Hobo

Hobo is distributed under the terms of the [MIT license](http://www.opensource.org/licenses/mit-license.php).

*PLEASE NOTE* Hobo currently requires Rails 2.1

It's a good idea to have a quick read of the [status](/blog/status/) page before downloading.

You can find the Hobo Manual on the [Docs Page](/blog/docs/).

Hobo is distributed in two forms, a gem and a plugin (svn repo).

### Hobo Gem

The gem is ideal for trying out Hobo with a new app. It gives you a single command:

    $ hobo <app-name>

It works just like the `rails` command, creating a blank Rails application pre-configured for Hobo. 

To install, simply

        $ gem install hobo

### Hobo plugin

If you want to add Hobo to an existing application, first do:

    $ ./script/plugin install svn://hobocentral.net/hobo/trunk
    $ ./script/generate hobo --add-routes

(the flag tells tells the generator to modify your config/routes.rb)

Then there are a few optional steps, depending on which Hobo features you're after. In the screencast you've seen:

#### Hobo Rapid and the default theme:

	$ ./script/generate hobo_rapid --import-tags

(the flag tells the generator to add some necessary tags to your application.dryml)
	
#### Hobo's user model:

	$ ./script/generate hobo_user_model user
	
#### The automatic front page, signup/login and search:

    $ ./script/generate hobo_front_controller front --add-routes --delete-index
	
(the flags tell the generator to add some new routes to config/routes.rb and to delete public/index.html so the front page will work)

### Learning Hobo

Please now head over to the [documentation](/blog/docs) page!

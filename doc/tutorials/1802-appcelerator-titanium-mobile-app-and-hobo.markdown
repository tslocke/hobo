# Appcelerator Titanium (Mobile App) and Hobo

Originally written by mdkarp on 2012-02-11.

This recipe answers [How to create a iPhone or mobile layout](/manual/faq/30-how-to-create-a-iphone-or)

Hi all,

I've tried searching for documentation on using Titanium (or anything) to make a mobile app (iOS/Android) from a Hobo app.  I wanted to use Hobo both as a front-end and a back-end.  While, I have seen this documented well outside of the Hobo world, I had not seen much on the combo of the two.  (As always throughout, please correct me if I am wrong.)

An example of a combo Rails/iPhone app is [here](https://github.com/clarkware/budgets-iphone)

However, given I don't know Objective-C, and I like the Hobo-style...so I set out with [Appcelerator](http://www.appcelerator.com/).

-----

The first issue was authentication.  I knew I did not want to get deep into how Hobo authenticates, so I decided to use "Basic Authentication" - passing the username and login in the [HTTP header.](http://en.wikipedia.org/wiki/Basic_authentication)  NOTE that this is wildly not secure unless you use HTTPS, which I am planning to use in production (unless someone comes up with a better idea).

In general, I followed this really amazing [tutorial.](http://mobile.tutsplus.com/tutorials/appcelerator/titanium-user-authentication/)  Also, [here](http://timneill.net/2011/06/simple-remote-requests-with-titanium-appcelerator/) is another guy that wrote a function to make all his data connections.

I just made a new controller method that just returns some basic user information, in a controller that is protected by login (by adding the below to one of my controllers).  

     before_filter :login_required


This way Appcelerator etiher gets JSON information or redirected to the login page, which results in an error.  From then on, in the header of the communication, I just pass what was given to be as a "Set-Cooke" back as a "Cookie."  (Header fields are described [here](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields).)

There are a few important nuances at this point:

1) Appcelerator errors out whenever you have an HTTP error on the Rails side (mostly manifests as "406 Not Acceptable." You must set the [Content-Type header.](http://developer.appcelerator.com/question/116980/iphone--rails--xhr--undefined-method-tosym-for-nilnilclass#203901)


     xhr.open('GET', url, false);
     xhr.setRequestHeader('Content-Type', 'application/json');
     xhr.send(); 


2) Pass authentication details [encoded in Base64](http://developer.appcelerator.com/question/120731/xhr-authentication-with-restful-api)

3) Store the cookie details in an [Appcelerator "property"](http://developer.appcelerator.com/question/117952/remember-me--session-implementation)

4) Appcelerator has what I think is a bug, and sometimes does not like the cookies that Hobo produces.  When you pass the header back to Hobo, you have to use ["cookie"](http://developer.appcelerator.com/question/118509/can-i-set-cookie-whose-value-include-equal-on-http-request) instead of "Cookie" (otherwise it errors out).


Creating methods in the controller (in Hobo) that send JSON is really easy.  It is quite awesome actually.  More on that [here.](http://stackoverflow.com/questions/2566759/how-can-i-generate-json-from-respond-to-method-in-rails)

In general you can simply do something like this:


     show_action :new_show

     def new_show
         hobo_show do
             render :json => @this.to_json
         end
     end

I mainly created new methods just so I didn't mess up the old ones, and so I did not have to deal with the respond_to and content-type issues.  There are some create tutorials on what to do with the data in Appcelerator once you have it.  [This one!](http://developer.appcelerator.com/blog/2011/08/handling-remote-data-with-httpclient-and-json.html)

Also, one more thought on this - get the [KitchenSink app](https://github.com/appcelerator/KitchenSink)!  You can copy and paste components practically.

I am about to embark on writing the part that allows me to create data on the mobile side, and pass it back up.  I'm not sure how this will pan out, but I think it will probably involve turning off [protect from forgery](http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html#method-i-protect_from_forgery) (that token on the web-side forms....or possibly, this might not be a problem with POST requests??)

-----

Please punch holes in this - I want to hear what has worked for others, and what might be wrong with what I am doing.  It also took me a while to find these resources, so I thought it would be important to share.

Also given the text java-script field definitions, and the general simplicity, I could see writing generators to make Appcelerator components from Hobo models!!  Anyone interested??

Cheers!




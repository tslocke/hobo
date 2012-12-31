# Ajax login form

Originally written by Bryan Larsen on 2010-02-21.

(Note that this recipe requires Hobo 1.1 or the latest version from [github](http://github.com/tablatom/hobo))

On a recent site I worked on, we wished to be able to create an order without logging in.  The solution we came up with was to replace the "save" button with an ajax login form.

Typically, AJAX forms are trivially easy to do in Hobo, but there's a few things that made this recipe a little less trivial.

1.  HTML does not allow nested forms, so the login form is actually placed outside of the order form.

2.  We moved the flash messages to ensure that users still received login failure messages.

3.  Hobo only updates a single part after AJAX.  In our scenario, we had two portions that needed updating -- the actions parameter in the form and the div after the form.  Usually you can just update all or most of the page when you have several portions to update, but we didn't want to lose the user's order.   Instead, we used Javascript for the second update.

4. In our application, Orders are created via a lifecycle method called "initiate".   However, guests are not allowed to trigger the method.   So the generated initiate-form does not work.   However, `<form with="&Order.new" lifecycle="initiate">` does.

Here's the DRYML:

    <content: with-flash-messages="&false">
      <section>
        <form with="&Order.new" lifecycle="initiate">
          <actions: class="#{'hidden' unless logged_in?}"/>
        </form>
        <div class="span-5 last">
          <do part="log-in-part">
            <unless test="&logged_in?">
              <flash-messages/>
              <login-form update="log-in-part" action="user_login_path" user-model="&User" success="GHF2.guestOrderLogin()"/>
            </unless>
          </do>
        </div>
      </section>
    </content:>

and the Javascript:

    guestOrderLogin: function() {
        jQuery('.actions').removeClass('hidden');
    }



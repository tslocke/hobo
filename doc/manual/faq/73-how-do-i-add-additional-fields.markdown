# How do I add additional fields to the signup page?

Originally written by kevinpfromnm on 2010-08-20.

I've got an extended model with fields for city, address, phone, fax
etc and yet they don't show up in my form signup. In my
application.dryml I've created:

    <extend tag="signup-form" for="User">
      <old-signup-form merge>
        ->>>
      </old-signup-form >
    </extend>

It is my understanding that this should give me the old form and
using

    ->>> <field-list: fields="city, province"/>

and the like where the arrow is should extend my form yet it gives me
a blank page and the form list overrides not appends the form. Also
when i try to override i often get

    undefined method `confirm_password' for #<User:

and such. Depending on what the field name is. How and where do I fix
all that ?

Thanks in advance. 
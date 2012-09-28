Hobo Permission System
{.document-title}

This chapter of the Hobo manual describes the permission system. The permission system is an extension to active record that allows you to define which actions on your models are permitted by which users. Hobo's controllers and DRYML tag libraries use this information to automatically customise their behaviour according to your definitions.


Contents
{: .contents-heading}

- contents
{:toc}



# Introduction

One of the core pieces of the Hobo puzzle is the permission system. The permission system itself lives in the model layer - it is a set of extensions to Active Record models. It's not a particularly complex set of extensions but the overall effect in Hobo is very powerful. This comes not so much from the permission system itself, but from how it is *used*. Hobo's controllers use the permission system to decide if a given request is allowed or not. In the view layer, the Rapid tag library uses the permission system to decide what to render for the currently logged in user.

To understanding how it all fits together, it's helpful to be clear about this distinction. The permission system is a model level feature, but it is *used* in both the controller and view layers. This guide will be mostly about how it all works in the model layer, but we'll also talk a little about how the controllers and tags use the permissions.

At it's heart, the permission system is fairly simple, it just provides methods on each model that allow the following four questions to be asked:

Is a given user allowed to

 - *Create* this record?
 - *Update* the database with the current changes to this record? (thanks to ActiveRecord's ability to track changes)
 - *Destroy* the current record.
 - *View* the current record, or an individual attribute thereof.
 
There is also a fifth permission, which is more of a pseudo permission. Can this user

 - *Edit* a specified attribute of the record
 
We call this a pseudo permission because it is not a request to actually *do something* with the record. It is more like asking: if, at some point in the future, the user tries to update this attribute, will that be allowed? Clearly edit permission is closely related to update permission, but it's not quite the same. In fact, you often don't need to declare edit permissions because Hobo can figure them out from your update permission. We'll cover this in more detail later, but for now just be aware that edit permission is a bit of an odd-one-out.


# Defining permissions

In a typical Hobo app, the place where the permission system is most prominent in your own code is your permission declarations. These are methods which you define on your models, known as "permission methods". These methods are where you tell the permission system who is allowed to do what. The permission methods are called by the framework - it is unusual to call them yourself.


## The four basic permission methods

When you generate a new Hobo model, you get stubs for the following methods.

 - `def create_permitted?`
 - `def update_permitted?`
 - `def destroy_permitted?`
 - `def view_permitted?(attribute)`
 
The methods must return true or false to indicate whether or not the operation is allowed. We'll see some examples in a moment but we first need to look at what information the methods have access to.


### `acting_user`

The user performing the action is available via `acting_user` method. This method will always return a user object, even if no one is logged in to the app, because Hobo has a special `Guest` class to represent a user that is not logged in. Two useful methods that are available on all Hobo user objects are:

 - `guest?` -- returns true if the user is a guest, i.e. no-one is logged in.
 - `signed_up?` -- returns true if the user is a not a guest.

So for example, to specify that you must be logged in to create a record:

    def create_permitted?
      acting_user.signed_up?
    end
{.ruby}

It's also common to compare the `acting_user` with associations on your model, for example, say your model has an owner:

    belongs_to :owner, :class_name => "User"
{.ruby}   

You can assert that only the owner can make changes like this:

    def update_permitted?
      owner == acting_user
    end
{.ruby}

There is a downside to that method -- the `owner` association will be fetched from the database. That's not really necessary, as the foreign key that we need has already been loaded. Fortunately Hobo adds a comparison method for every `belongs_to` that avoids this trip to the database:

    def update_permitted?
      owner_is? acting_user
    end
{.ruby}


### Change tracking

When deciding if an update is permitted (i.e. in the `update_permitted?` method), it will often be important to know what exactly has changed. In a previous version of Hobo we had to jump through a lot of hoops to make this information available. No longer -- Active Record now tracks all changes made to an object. For example, say you wish to find out about changes to an attribute `status`. The following methods (among others) are available:

 - `status_changed?` - returns true iff the attribute has been changed
 - `status_was` - returns the old value of the attribute
 
Note that these methods are only available on attributes, not on associations. However, as a convenience Hobo models add `*_changed?` for all `belongs_to` associations.

For example, the following definition means that only signed up users can make changes, and the `status` attribute cannot be changed by anyone:

    def update_permitted?
      acting_user.signed_up? && !status_changed?
    end
{.ruby}

As a stylistic point, sometimes it can be clearer to use early returns, rather than to build up a large and complex boolean expression. This approach is also a bit easier to apply comments to. For example:

    def update_permitted?
      # Must be signed up:
      return false unless acting_user.signed_up?
      
      !status_changed?
    end
{.ruby}

### Change tracking helpers

Making assertions about changes to many attributes can quickly get tedious:

    def update_permitted?
      !(address1_changed? || address2_changed? || city_changed? || zipcode_changed?)
    end
{.ruby}

The permission system provides four helpers to make code like this more concise and clearer. Each of these methods are passed one or more attribute names.

- `only_changed?` -- are the attributed passed the only ones that have changed?
- `none_changed?` -- have none of the attributes passed been changed?
- `any_changed?`  -- have any of the attributes passed been changed?
- `all_changed?`  -- have all of the attributes passed been changed?

So, for example, the previous `update_permitted?` could be simplified to:

    def update_permitted?
      none_changed? :address1, :address2, :city, :zipcode
    end
{.ruby}

Ruby tip: if you want to pass an array, use Ruby's 'splat' operator:

    READ_ONLY_ATTRS = %w(address1 address2 city zipcode)

    def update_permitted?
      none_changed? *READ_ONLY_ATTRS
    end
{.ruby}


Note that you can include the names of `belongs_to` associations in your attribute list.


### Examples

Let's go through a few examples.

Here's a definition that says you cannot create records faking the `owner` to be someone else, and `state` must be 'new':

    def create_permitted?
      return false unless owner_is? acting_user
      
      state == "new"
    end
{.ruby}

Note that by asserting `owner_is? acting_user` you are implicitly asserting that the `acting_user` is signed up, because `owner` can never be a reference to a guest user.

A common requirement for update permission is to restrict the list of fields that can be changed according to the type of user. For example, maybe an administrator can change anything, but a non-admin can only change a given set of fields:

    def update_permitted?
      return true if acting_user.administrator?
      
      only_changed? :name, :description
    end
{.ruby}

Note that we're assuming there is an `administrator?` method on the user object. Such a method is not built into Hobo, but Hobo's default user generator does add this to your model. We'll discuss this in more detail later on.

A typical destroy permission might be that administrators can delete anything, but non-admins can only delete the record if they own it:

    def destroy_permitted?
      acting_user.administrator? || owner_is?(acting_user)
    end
{.ruby}
    

### View permission and `never_show`

As you may have noticed when we introduced the permissions above, the `view_permitted` method differs from the other three basic permissions in that it takes a single parameter:

    def view_permitted?(attribute)
      ...
    end
{.ruby}

The method is required to do double duty. If the permission system needs to determine if the `acting_user` is allowed to view this record as a whole, `attribute` will be nil. Otherwise `attribute` will be the name of an attribute for which view permission is requested. So when defining this method, remember that `attribute` may be nil.

There is also a convenient shorthand for denying view permission for a particular attribute or attributes:

    class MyModel
      ...
      never_show :foo, :baa
      ...
    end
{.ruby}

View and edit permission will always be denied for those attributes.


## Edit Permission

Edit permission is used by the view layer to determine whether or not to render a particular form field. That means it is not like the other permission methods, in that it's not actually a request to view or change a record. Instead it's more like a preview of update permission. Asking for edit permission is a bit like asking: will update permission be granted if a change is made to this attribute? A common response to that question might be: it depends what you're changing the attribute to. And therein lies the difference between update permission and edit permission. With update permission, we are dealing with a known quantity -- we have a set of concrete changes to the object that may or may not be permitted. With edit permission, the value that the attribute will become is not known (because the user hasn't submitted the form yet).

Despite that difference edit permission and update permission are obviously very closely related. Because saving you work is what Hobo is all about, the permission system contains a mechanism for deriving edit permission based on your `update_permitted?` method. For that reason, the `edit_permitted?` method:

    def edit_permitted?(attribute)
      ...
    end
{.ruby}

often does not need to be implemented.

### Protected, read-only, and non-viewable attributes

Rails provides a few ways to prevent attributes from being updated during 'mass assignment'

 - `attr_protected` 
 - `attr_accessible`
 - `attr_readonly`
 
(You can look these up in the regular Rails API reference if you're not familiar with them).

Before the `edit_permitted?` method is even called, Hobo checks these declarations. If changes to any attribute is prevented by these declarations, they will automatically be recognised as not editable.

Similarly, if a virtual attribute is read-only in the Ruby sense (it has no setter method), that tells Hobo it is not editable. And finally, fields that are not viewable are implicitly not editable either.

Tip: if a particular attribute can *never* be edited by any user, it's simplest to just declare it as `attr_protected` or `attr_readonly` (read-only attributes can be set on creation, but not changed later). If the ability to change the attribute either depends on the state of the record, or varies from user to user, `attr_protected` and the rest are not flexible enough -- define permission methods instead.

We'll now take a look at how `edit_permitted?` is provided automatically, and then cover the details of defining edit permission yourself.

### Deriving edit permission

To figure out edit permission for a particular attribute, based on your definition of `update_permitted?`, Hobo calls your `update_permitted?` method, but with a special trick in place.

If your `update_permitted?` attempts to access the attribute under test, Hobo intercepts that access and says to itself: "Aha! the permission method tried to access the attribute, which means permission to update *depends on the value of that attribute*". Given that we don't know what value the attribute will have *after the edit*, we had better be conservative. The result is `false` - no you cannot edit that attribute.

If, on the other hand, the permission method returns true without ever accessing that attribute, the conclusion is: update permission is granted regardless of the value the attribute. No matter what change is made to the attribute, update permission will be granted, and therefore edit permission can be granted.

Neat eh? It's not perfect but it sure is useful. Remember you can always define `edit_permitted?` if things don't work out. Also note that if edit permission is incorrect, this does *not* result in a security hole in your application. An edit control may be rendered when it really should not have been, but on submission of the form, the change to the database is policed by `update_permitted?`, not `edit_permitted?`.

In case you're interested, here's how Hobo intercepts those accesses to the attribute under test. A few singleton methods are added to the record (i.e. methods are defined on the record's metaclass). These give special behaviour to this one instance. In effect these methods make one of the models attributes 'undefined'. Any access to an undefined attribute raises `Hobo::UndefinedAccessError`, which is caught by the permission system, and edit permission is denied. 

Say a test is being made for edit permission on the `name` attribute, the following methods will be added:

 - `name` - raises `Hobo::UndefinedAccessError`
 - `name_change` - raises `Hobo::UndefinedAccessError`
 - `name_was` - returns the actual current value (because this will be the old value after the edit)
 - `name_changed?` - returns true
 - `changed?` - returns true
 - `changed` - returns the list of attributes that have changed, including `name`
 - `changes` - raises `Hobo::UndefinedAccessError`
 
After the edit check those singleton methods are removed again.


### Defining edit permission

If the mechanism described above is not adequate for some reason, you can always define edit permission yourself. If the derived edit permission is not correct for just one field, it's possible to define edit permission manually for just that one field, and still have the automatic edit permission for the other fields in your model.

To define edit permission for a single attribute (and keep the automatically derived edit permission for the others), define `foo_edit_permitted?` (where `foo` is the name of your attribute). For example, if the attribute is `name`:

    def name_edit_permitted?
      acting_user.administrator?
    end
{.ruby}

To completely replace the derived edit permission with your own definition, just implement `edit_permitted?` yourself:

    def edit_permitted?(attribute)
      ...
    end
{.ruby}

The `attribute` parameter will either be the name of an attribute, or nil. In the case that it is nil, Hobo is testing to see if the current user has edit permission "in general" for this record. For example, this would be use to determine whether or not to render an edit link.


# Permissions and associations

So far we've focussed on policing changes to basic data fields, but Hobo supports multi-model forms, so we also need to place restrictions on associated records. We need to specify permissions regarding:

 - Changes to the target of a `belongs_to` association.
 - Adding and removing items to a `has_many` association.
 - Changes to the fields of any related record
 
If we think in terms of the underlying database, it's clear that every change ultimately comes down to things that we have already covered - creating, updating and deleting rows. So the permission system is able to covers these cases with a simple rule:

 - If you make a change to a record via one of the `user_*` methods, (e.g. `user_create`), and
 - as a result of that change, related records are created, updated or destroyed, then
 - the `acting_user` is propagated to those records, and 
 - any permissions defined on those records are enforced.
 
All we have to do then, is think of everything in terms of the records that are being created, modified or deleted, and it should be clear how which permissions apply. For example:

 - Change the target of a `belongs_to` required update permission on the owner record.
 - Adding a new record to a `has_many` association requires create permission for that new record.
 - Adding and removing items to a `has_many :through` requires create or destroy permission on the join model.

So there really is no special support for associations in the permission system, other than the rule described above for propagating the `acting_user`.

## Testing for changes to `belongs_to` associations

As discussed, no special support is needed to police `belongs_to` associations, you can just check for changes to the foreign key. For example:

    belongs_to :user

    def update_permitted?
      acting_user.administrator || !user_id_changed?
    end
{.ruby}

Although that works fine, it feels a bit low level. We'd much rather say `user_changed?`, and in fact we can. For every `belongs_to` association, Hobo adds a `*_changed?` method, e.g. `user_changed?`. In addition to this, the attribute change helpers -- `only_changed?`, `none_changed?`, `any_changed?` and `all_changed?` -- all accept `belongs_to` association names along with regular field names.

# The permissions API

It is common in Hobo applications, especially small ones, that although you *define* permissions on your models, you never actually call the permissions API yourself. The model controller will use the API to determine if POST and PUT requests are allowed, and the Rapid tags in the view layer will use the permissions API to determine what to render.

When you're digging a bit deeper though, customising the controllers and the views, you may need to use the permission API yourself. That's what we'll look at in this section.

## The standard CRUD operations.

ActiveRecord provides a very simple API for the basic CRUD operations.

 - Create -- `Model.create` or `r = Model.new; ...; r.save`
 - Read   -- `Model.find`, then access the attributes on the record
 - Update -- `record.save` and `record.update_attributes`
 - Delete -- `record.destroy`
 
The Hobo permission system adds "user" versions of these methods. For example, `user_create` is like `create`, but takes the "acting user" as an argument, and performs a permission check before the actual create. The full set of class (model) methods are:

 - `Model.user_find(user, ...)`
 
   A regular find, followed by `record.user_view(user)`
  
 - `Model.user_new(user, attributes)`

   A regular new, then `set_creator(user)`, then `record.user_view(user)`. If a block is given, the `yield` is after the `set_creator` and
  before the `user_view`

 - `Model.user_create(user, attributes)` (and `user_create!`)
 
   As with regular `create`, attributes can be an array of hashes, in which case multiple records are created. Equivalent to `user_new`
   followed by `record.user_save`. The `user_create!` version raises an exception on validation errors.
 
The instance (record) methods are:

 - `record.user_save(user)` (and `user_save!`)
 
   A regular `save` plus a permission check. If `new_record?` is true, checks for create permission, otherwise for update permission.
   
 - `record.user_update_attributes(user, attributes)` (and `user_update_attributes!`)
 
   A regular `update_attributes` plus the permission check. If `new_record?` is true, checks for create permission, otherwise for update
   permission.
   
 - `record.user_view`
  
   Performs a view permission check and raises `PermissionDeniedError` if it fails
 
 - `record.user_destroy` 
 
   A regular `destroy` with a permission check first.

 
## Direct permission tests

The methods mentioned in the previous section perform the appropriate permission tests along with some operation. If you want to perform a permission test directly, the following methods are available:

 - `record.creatable_by?(user)`
 - `record.updatable_by?(user)`
 - `record.destroyable_by?(user)`
 - `record.viewable_by?(user, attribute=nil)`
 - `record.editable_by?(user, attribute=nil)`
 
There is also 

 - `method_callable_by?(user, method_name)`
 
Which is related to web methods, which we'll cover later on.

You should always call these methods, rather than calling the `..._permitted?` methods directly, as some of them have extra logic in addition to the call to the `..._permitted?` method. For example, `editable_by?` will check things like `attr_protected` first, and then call `edit_permitted?`
 
 
## Create, update and destroy hooks

In addition to the methods described in this section, the permission system extends the regular `create`, `update` and `destroy` methods. If `acting_user` is set, each of these will perform a permission check prior to the actual operation. This is illustrated in the very simple implementation of, for example user save:

    def user_save(user)
      with_acting_user(user) { save }
    end
{.ruby}

(`with_acting_user` just sets `acting_user` for the duration of the block, then restores it to it's previous value)


# Permission for web methods

In order for a web method to be available to a particular user, a permission method must be defined (one permission method per web method). For example, if the web method is `send_reminder_email`, you would define the permission to call that in:

    def send_reminder_email_permitted?
      ...
    end
{.ruby}

As mentioned previously, you can test method-call permission directly with:

    record.method_callable_by?(user, :send_reminder_email)


# `after_user_new` -- initialise a record using `acting_user`

Often we would like to initialise some aspect of our model based on who the `acting_user` is. A very common example would be to set an "owner" association automatically. Hobo provides the `after_user_new` callback for this purpose:

    belongs_to :owner, :class_name => "User"
    
    after_user_new { |r| r.owner = r.acting_user }
{.ruby}

Note that `after_user_new` fires on both `user_new` and `user_create.`

The need for an "owner association" is so common that Hobo provides an additional shortcut for it:

    belongs_to :owner, :class_name => "User", :creator => true
{.ruby}

Other situations can be more complex, and the `:creator => true` shorthand may not suffice. For example, an "event" model might need to be associated with the same "group" as the acting user. In this case we go back to the `after_user_new` callback:

    class Event 
      belongs_to :group
      
      after_user_new { |event| event.group = event.acting_user.group }
    end
{.ruby}


OK but what does all this have to do with permissions? It is quite common that you *need* this information to be in place in order to confirm if permission is granted. For example:

    def create_permitted?
      acting_user.group == group
    end
{.ruby}

This definition says that a user can only create an event in their own group.

When we combine the two...

    after_user_new { |event| event.group = event.acting_user.group }

    def create_permitted?
      acting_user.group == group
    end
{.ruby}

...a neat thing happens. A signed up user *is* allowed to create an event, because the callback ensures that the event is in the right group, but if an attempt is made to change the group to a different one, that would fail. The edit permission mechanism (described in a previous section) can detect this, so the end result is that (by default) your app will have the "New Event" form, but the form control for choosing the group will be automatically removed. The event will be automatically assigned to the logged in user's group. I love it when a plan comes together!


# Permissions vs. validations

It may have occurred to you that there is some overlap between the permission system and ActiveRecord's validations. To an extend that's true: they both provide a way to prevent undesirable changes from making their way into the database. The line between them is fairly clear though:

 - Validations are appropriate for "normal mistakes".
 
  A validation "error" is not really an application error, but a normal occurrence which is reported to the user in a helpful manner.
 
 - Permissions are appropriate for preventing things that *should never happen*.
 
  Your user interface should provide no means by which a permission denied error can occur. Permission errors should only come from
  manually editing the browser's address bar, or from unsolicited form posts.
  
In Rails code, it's not uncommon to see validations used for both of these reasons. For example, the UI may provide radio buttons to chose "Male" or "Female", and the model might state:

    validates_inclusion_of :gender, :in => %w(Male Female)
{.ruby}
    
In normal usage, no one will ever see the message that gets generated when this validation fails. Effectively it's being used as a permission. In a Hobo app it might be better to use the permission system for this example, but the declarative `validates_inclusion_of` is quite nice, so if you do use it we'll turn a blind eye.


# The `administrator?` method

The idea that your user model has a boolean method `administrator?` is bit of a strong assumption. It fits for many apps but might be totally inappropriate for many others. Although you've probably seen this method a lot, it's important to clarify that it's not actually part of Hobo. Eh what?

`administrator?` is only a part of Hobo insofar as:

 - The user model created by the `hobo_user_model` generator contains a boolean field `administrator`
 
 - The `Guest` model created by the `hobo` generator has a method `administrator?` which just returns false.
 
 - The default permission stubs generated by `hobo_model` require `acting_user.administrator?` for create, update and destroy permission.
 
That's it. `administrator?` is a feature of those three generators, but is not a feature of the permission system itself, or any other part of the Hobo internals. The generated code is just a starting point. Two common ways you might want to change that are:

 - Get rid of the `administrator` field in the `User` model, and define a method instead, for example.
 
        def administrator?
          roles.include?(Role.administrator)
        end
{.ruby}

 - Get rid of that field, and of all calls to `administrator?` from your models' permission methods. Those are just stubs that you are
   expected to replace

At some point we may add an option to the generators so you will only get `administrator?` if you want it.

 
# View helpers

TO DO

Quick version - five permission related view-helpers are provided:

 - `can_create?(object=this)`
 - `can_update?(object=this)`
 - `can_edit?` -- arguments are an object, or a symbol indicating a field (assumes `this` as the object), or both, or no arguments
 - `can_delete?(object=this)`
 - `can_call?` -- arguments are an object and a method name (symbol), or just a method name (assumes `this` as the object)


# Permissions in the Rapid tag library

TO DO (use of permissions by view, input, form etc.)


# Why no roles?

TO DO

People often expect a role based permissions system. What we've provided is a simple general-purpose system. There are many different ways to build a role-based system. We've just provided the tools with which to build one if you need one.

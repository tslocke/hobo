# How do I pass back an extra field from a form?

You can customize the fields in a form by setting the fields attribute in the field-list parameter.  Suppose we want our form to contain two fields, bar which exists in the database, and foo which does not.   Hobo handles bar automatically, but we have to add extra code for foo.   There are two good options.   The first is to add it in the view:

     <extend tag="form" for="MyModel">
       <old-form merge>
         <field-list: fields="foo,bar">
           <foo-view:>Option 1: HTML here</foo-view:>
         </field-list:>
       </old-form>
     </extend>

The other option is to add virtual attributes to your model:

    class MyModel < ActiveRecord::Base
      ...
      attr_accessible :foo, :bar

      def foo
        "FOO!"
      end

      def foo=(new_value)
        fooify(new_value)
      end
    end

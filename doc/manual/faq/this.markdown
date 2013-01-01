# What's the difference between `this` and `@foos`

The default index action for a hobo controller named FoosController will assign the list of foos to both `this` and `@foos`.

In the view, `this` will change, always holding the current context while `@foos` won't change unless you do it yourself.

Hobo controllers contain methods that ensure that those two variables are initially set to the same value.   So these three lines are essentially identical.

     @foos = Foo.all
     self.this = Foo.all
     @foos = self.this = Foo.all


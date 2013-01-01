# polymorphic associations such as a comment model

Originally written by kevinpfromnm on 2010-08-04.

This question answered by recipe: [Simple Cross-Model Comments](/tutorials/7-simple-cross-model-comments)

Dear all,

I am trying to add comments to a hobo project.
I would like multiple model to be commentable.

So I create a comment model with

belongs_to :commentable, :polymorphic => true

and to each commentable thing, I had

has_many :comments, :as => :commentable

I wonder now how to create comments.

I would like to create a link "add comment" to the other models, and
this link would contain the right :container_id and :container_type.
I would also like these fields not be editable.

How should I do that?
Should I create my own new and create controllers that extract the
right parameters? Is there something more Hobo-y to do?

How to ensure that the field are not editable? (Usually, I use
after_user_new callback + permission for create, but I can't see how
to use it in such a setting)

Best regards,

Nicolas.
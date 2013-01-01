# Where do I put the DRYML for owner actions?

Owner actions are added to an application like this:

    class CommentsController < ApplicationController
       hobo_model_controller
       auto_actions_for :post, [:index, :new, :create]
    end

The URL for the new action would be:

    /posts/1/comments/new

You can customize the page by creating `app/views/comments/new_for_post.dryml`:

    <new-for-post-page>
      <content-body:>
        ...
      </content-body:>
    </new-for-post-page>

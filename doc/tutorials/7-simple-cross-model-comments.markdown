# Simple Cross-Model Comments

Originally written by adamski on 2008-10-23.

This recipe answers [Comments in Hobo](/questions/16-comments-in-hobo)

This recipe answers [polymorphic associations such as a comment model](/questions/53-polymorphic-associations-such-as-a-comment)

After posting the question, and recently getting into polmorphic stuff with Rails and Hobo, I realised how easy it is to set up cross-model comments.

(this assumes you want to associate a comment with a user)

    ./script/generate hobo_model comment body:text commentable_id:integer commentable_type:string user_id:integer
    ./script/generate hobo_model_controller comment
    ./script/generate hobo_migration 


then in any model you want to be commentable:

    has_many :comments, :as => :commentable, :dependent => :destroy

in my application.dryml I added a card for Comments: 

    <def tag="card" for="Comment">
	<div class="card linkable comment">	      
    	    <h5><view with="&User.find(this.user_id)"/> wrote:</h5> 
    		<view:body/><br/>
    		<view:created_at/>		
    		<if test="&this.user_id == current_user.id">
    			<div class="delete">			
    				 <%= link_to 'delete', { :controller => 'links', :action => 'destroy',
                                       :id => this.id.to_s }, 
                                       :confirm => "Are you sure you want to delete this comment?",
                                       :method => :delete %>				
    			</div>
    		</if>
    	</div>  
    </def> 

and a tag for adding a new comment to an object:

    <def tag="add-comment" attrs="object">
    	<if test="&object">
    		<form with="&Comment.new">
    		  Add a new comment<br/>
    		  <textarea class="body-tag comment-body"  id="comment[body]"  name="comment[body]" >
    		  <input  id="comment[commentable_type]" name="comment[commentable_type]" type="hidden" value="&object.class.name" />	  	
    		  <input  id="comment[commentable_id]" name="comment[commentable_id]" type="hidden" value="&object.id" />	  	
    		  <input  id="comment[user_id]" name="comment[user_id]" type="hidden" value="&current_user.id" />	  	
    		  <submit label="New Comment"/>
    		</form>
    	</if>
    	<else>
    		<p>Error (add-comment): Object not given - use add-comment object="&blah"</p>
    	</else>
    </def>




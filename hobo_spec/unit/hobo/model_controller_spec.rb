require File.dirname(__FILE__) + '/../../spec_helper'

# Uncomment to see the SQL as the tests run
#RAILS_DEFAULT_LOGGER.instance_variable_set("@logdev", Logger::LogDevice.new(STDOUT))

describe PostsController, :behaviour_type => :controller do 
  
  fixtures :users, :administrators, :posts, :comments, :categorisations
  
  it "should not allow guest to create a new post with a post to 'create'" do 
    post "create", {:post => {:title => "test post", :body => "body of test post"}}
    Post.find_by_title("test post").should == nil
    response.headers["Status"].should == "403 Forbidden"
  end
  
  it "should allow test_user to create a new post with a POST to 'create'" do 
    user_session
    post "create", {:post => {:title => "test post abc", :body => "body of test post"}}

    response.should be_redirect

    p = Post.find_by_title("test post abc")
    p.should_not == nil
    p.body.should == "body of test post"
  end
  
  it "should allow comments on a post to be created in the same request" do 
    user_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :comments => {
          "+1" => {:body => "nice post", :author => "fred"},
          "+2" => {:body => "yeah cool", :author => "jim"}
        }
      }}
    
    response.should be_redirect
    
    p = Post.find_by_title("test post abc")
    p.comments.every(:body).should == ["nice post", "yeah cool"]
    p.comments.every(:author).should == ["fred", "jim"]
  end
  

  it "should not be possible to assign a comment to a different post in violation of create permission" do
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :comments => {
          "+1" => {:body => "nice post", :author => "fred", :post => "@post_2"},
        }
      }}
    response.headers["Status"].should == "403 Forbidden"
    Post.find_by_title("test post abc").should == nil
  end

  
  it "should allow a post to be created belonging to a given user" do
    admin_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :user => "@user_1"
      }}
    response.should be_redirect
    Post.find_by_title("test post abc").user.should == User.find(1)
  end

  
  it "should not allow a post that violtaes create permission to be created" do
    # Here User[1] tries to create a post with author == User[2]
    user_session
    post "create", {:post => {
        :title => "test post abc", :body => "CANNOT CREATE",
      }}
    response.headers["Status"].should == "403 Forbidden"
    Post.find_by_title("test post abc").should == nil
  end 

  
  it "should override a change to the creator attribute (and use current user instead)" do
    # Here User[1] tries to create a post with author == User[2]
    user_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :user => "@user_2"
      }}
    response.should be_redirect
    Post.find_by_title("test post abc").user.should == users(:test_user)
  end 
  
  
  it "should be possible to create a new categorisation with the post, using the category name" do 
    user_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :categorisations => {
          "+1" => { :category => "News" }
        }
      }}
    Post.find_by_title("test post abc").categories.every(:name).should == ["News"]
  end
  
  
  it "should be possible for an admin to create a new category along with the categorisation" do 
    admin_session
    post "create", { :post => {
        :title => "test post abc", :body => "body of test post",
        :categorisations => {
          "+1" => { "+category" => { :name => "Off Topic" } }
        }
      }}
    Post.find_by_title("test post abc").categories.every(:name).should == ["Off Topic"]
  end
  
  
  it "should be possible to update an existing post with a PUT" do
    user_session
    put "update", { :id => "1", :post => { :title => "nice new title" } }
    Post[1].title.should == "nice new title"
    response.should be_redirect
  end
  
  
  it "should be possible to update an associated comment at the same time as the post" do
    user_session
    put "update", { :id => "1", :post => { :comments => { "1" => { :body => "changed comment" }}}}
    Post[1].comments.first.body.should == "changed comment"
    response.should be_redirect
  end

  
  it "should not be possible to update a comment that belongs to a different post" do 
    user_session
    proc do 
      put "update", { :id => "1", :post => { :comments => { "3" => { :body => "changed comment" }}}}
    end.should raise_error(HoboError)
  end
  
  
  it "should be possible to delete a related record while updating" do 
    user_session
    put "update", { :id => 1, :post => { :comments => { "2" => "delete" }}}
    Post[1].comments.length.should == 1    
    response.should be_redirect
  end

  
  it "should not be possible to delete an unrelated record while updating" do 
    user_session
    proc do 
      put "update", { :id => 1, :post => { :comments => { "3" => "delete" }}}
    end.should raise_error(HoboError)      
  end
  
  
  it "should be possible to create new related objects while updating" do 
    user_session
    put "update", { :id => 1, :post => {
        :categorisations => { "+1" => { :category => "General" }},
        :comments => { "+1" => { :author => "Jim" }}
      }}
    Post[1].categories.every(:name).should == ["News", "General"]
    Post[1].comments.every(:author).should == ["mr x", "mr y", "Jim"]
  end
  
  
  def user_session
    session[:user] = users(:test_user).typed_id
  end
  
  def admin_session
    session[:user] = administrators(:test_admin).typed_id
  end
  
end

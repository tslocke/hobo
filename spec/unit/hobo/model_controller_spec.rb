require File.dirname(__FILE__) + '/../../spec_helper'

# Uncomment to see the SQL as the tests run
#RAILS_DEFAULT_LOGGER.instance_variable_set("@logdev", Logger::LogDevice.new(STDOUT))

describe PostsController, :behaviour_type => :controller do 
  
  fixtures :users, :administrators
  
  it "should not allow guest to create a new post with a post to 'create'" do 
    post "create", {:post => {:title => "test post", :body => "body of test post"}}
    Post.find_by_title("test post").should == nil
    response.headers["Status"].should == "403 Forbidden"
  end
  
  it "should allow test_user to create a new post with a post to 'create'" do 
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
  
  it "should allow a post to be created belonging to a given user" do
    admin_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :user => "@user_1"
      }}
    Post.find_by_title("test post abc").user.should == User.find(1)

    response.should be_redirect
  end

  
  it "should not allow a post to be created that violates create permissions" do
    # Here User[1] tries to create a post with author == User[2]
    user_session
    post "create", {:post => {
        :title => "test post abc", :body => "body of test post",
        :user => "@user_2"
      }}
    
    response.headers["Status"].should == "403 Forbidden"

    Post.find_by_title("test post abc").should == nil
  end
  
  
  def user_session
    session[:user] = users(:test_user).typed_id
  end
  
  def admin_session
    session[:user] = administrators(:test_admin).typed_id
  end
  
end

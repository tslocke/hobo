# Adding an RSS feed.

Originally written by kevinpfromnm on 2009-08-25.

This is mostly the same as standard rails.  Hobo does shorten the controller side if you don't need any filtering.

In your controller, add an index_action for your feed.

    index_action :rss

Hobo index actions will paginate for html requests but by default do not for xml requests.

Then add the view file under <code>/app/views/</code>controller<code>/rss.builder</code>

    xml.instruct! :xml, :version => "1.0"
    
    xml.rss "version" => "2.0" do
     xml.channel do
    
       xml.title       "news"
       xml.link        url_for(:only_path => false, :controller => 'posts')
       xml.description "news items"
    
       @posts.each do |post|
         xml.item do
           xml.title       post.title
           xml.link        url_for(:only_path => false, :controller => 'posts', :action => 'show', :id => post.id)
           xml.description post.body
           xml.updated_at  post.updated_at
           xml.guid        url_for(:only_path => false, :controller => 'posts', :action => 'show', :id => post.id)
         end
       end
    
     end
    end

The above is from a feed I created for a posts controller.  Substitute your fields as needed.


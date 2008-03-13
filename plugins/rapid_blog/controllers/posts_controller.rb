bundle_model_controller :BlogPost do
  
  auto_actions :all, :except => :index

  include_taglib "post_pages", :bundle => _bundle_
  
  feature :comments do 
    include_taglib "rapid_comments", :bundle => _comments_bundle_
  end
  

  def index
    respond_to do |wants|
      wants.html do 
        @posts_by_month = model.all_posts_by_month
        @rss_alternative_url = full_url(model) + ".rss"
        hobo_index
      end
      wants.rss do 
        response.headers['Content-Type'] = 'application/rss+xml'
        render :text => rss
      end
    end
  end


  index_action :archive do
    @this = model.all_posts_by_month
  end

  
  private
  
  def rss
    posts = model.published.send(_feed_[:scope]).all

    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => "1.0"
    xml.rss :version => 2.0 do
      xml.channel do
        xml.title       _feed_[:title] || model.name.titleize.pluralize
        xml.description _feed_[:description]
        xml.link        full_url(model)
        
        posts.each do |post|
          xml.item do 
            xml.title       post.title
            xml.pubDate     post.published_at
            xml.description post.body
            xml.link        full_url(post)
          end
        end
      end
    end
  end
  
  
  def full_url(target)
    "http://#{request.host_with_port}#{base_url}#{object_url(target)}"
  end

end

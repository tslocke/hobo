class BlogPost
  attr_accessor :id
  attr_accessor :title
  attr_accessor :body
  attr_accessor :published_at
  attr_accessor :author

  def initialize(options = {})
    self.id = options[:id] || 1
    self.title = options[:title] || 'A Blog Post'
    self.body = options[:body] || 'Some body content'
    self.published_at = options[:published_at] || Time.utc(2011,12,30,10,25)
    self.author = Author.new(options[:author] || {})
  end

  # needed for field= to work
  def [](idx)
    send(idx)
  end

  def url
    "/blog_posts/#{id}"
  end

  def name
    title
  end

end

class SpecialBlogPost < BlogPost

  def url
    "/special_blog_posts/#{id}"
  end

end

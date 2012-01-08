class Post
  attr_accessor :title

  def initialize(options={})
    self.title = options[:title] || 'A Post'
  end

  # needed for field= to work
  def [](idx)
    send(idx)
  end
end

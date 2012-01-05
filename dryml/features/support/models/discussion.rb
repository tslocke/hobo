class Discussion
  attr_accessor :name
  attr_accessor :posts

  def initialize(options={})
    self.name = options[:name] || 'Some Discussion'
    self.posts = options[:posts] || []
  end

  # needed for field= to work
  def [](idx)
    send(idx)
  end
end


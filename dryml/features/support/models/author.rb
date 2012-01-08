class Author
  attr_accessor :id
  attr_accessor :name

  def initialize(options={})
    self.id = options[:id] || 1
    self.name = options[:name] || 'Nobody'
  end

  # needed for field= to work
  def [](idx)
    send(idx)
  end

  def url
    "/authors/#{id}"
  end
end

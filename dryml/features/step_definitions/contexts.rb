When /^the current context is a blog post$/ do
  @locals ||= {}
  @locals[:this] = BlogPost.new
end

When /^the current context is a special blog post$/ do
  @locals ||= {}
  @locals[:this] = SpecialBlogPost.new
end

When /^the current context is an array$/ do
  @locals ||= {}
  @locals[:this] = %w(foo bar baz blam mumble)
end

When /^the current context is a list of discussions$/ do
  @locals ||= {}
  discussions = []
  (1..3).each do |i|
    posts = (1..i).to_a.map { |x| Post.new(:title => "Post #{x+3*i}") }
    discussions << Discussion.new(:name => "Discussion #{i}", :posts => posts)
  end
  @locals[:this] = discussions
end


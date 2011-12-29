When /^the current context is a blog post$/ do
  @locals ||= {}
  @locals[:this] = BlogPost.new
end

When /^the current context is an array$/ do
  @locals ||= {}
  @locals[:this] = %w(foo bar baz blam mumble)
end


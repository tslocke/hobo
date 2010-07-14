module Enumerable
  def group_by_with_metadata(&block)
    r=group_by_without_metadata(&block)
    r.each do |k,v|
      v.origin = origin
      v.origin_attribute = origin_attribute
      v.member_class = member_class
    end
    r
  end
  alias_method_chain :group_by, :metadata
end
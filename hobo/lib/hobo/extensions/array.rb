# Add support for type metadata to arrays

require 'will_paginate/array'

class Array

  attr_accessor :member_class, :origin, :origin_attribute

  def to_url_path
    base_path = origin.try.to_url_path
    "#{base_path}/#{origin_attribute}" unless base_path.blank?
  end

  def typed_id
    origin and origin_id = origin.try.typed_id and "#{origin_id}:#{origin_attribute}"
  end

  def paginate_with_hobo_metadata(*args, &block)
    collection = paginate_without_hobo_metadata(*args, &block)
    collection.member_class     = member_class
    collection.origin           = try.proxy_owner
    collection.origin_attribute = try.proxy_reflection._?.name
    collection
  end
  alias_method_chain :paginate, :hobo_metadata

end

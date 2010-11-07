# Add support for type metadata to arrays
class Array

  attr_accessor :member_class, :origin, :origin_attribute

  def to_url_path
    base_path = origin.try.to_url_path
    "#{base_path}/#{origin_attribute}" unless base_path.blank?
  end

  def typed_id
    origin and origin_id = origin.try.typed_id and "#{origin_id}:#{origin_attribute}"
  end

end

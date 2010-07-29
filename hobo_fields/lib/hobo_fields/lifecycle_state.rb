module HoboFields
  class LifecycleState < String
    
    COLUMN_TYPE = :string

    class << self
      attr_accessor :table_name
    end
    
    def to_html(xmldoctype = true)
      I18n.t("#{self.class.table_name}.states.#{self}", :default => self)
    end
  end
end

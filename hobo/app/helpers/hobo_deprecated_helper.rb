# as far as I can tell, these functions are no longer used.   It's
# theoretically possible that they are used in user apps somewhere,
# but unlikely
module HoboDeprecatedHelper
  if Rails.application.config.hobo.include_deprecated_helper
    protected
    def uid
      @hobo_uid ||= 0
      @hobo_uid += 1
    end

    def update_elements_class(updates)
      'update::'+comma_split(updates).join(':') unless updates.blank?
    end

    def js_str(s)
      if s.is_a? Hobo::RawJs
        s.to_s
      else
        "'" + s.to_s.gsub("'"){"\\'"} + "'"
      end
    end


    def make_params_js(*args)
      ("'" + make_params(*args) + "'").sub(/ \+ ''$/,'')
    end


    def nl_to_br(s)
      s.to_s.gsub("\n", "<br/>") if s
    end

    def transpose_with_field(field, collection=nil)
      collection ||= this
      matrix = collection.map {|obj| obj.send(field) }
      max_length = matrix.*.length.max
      matrix = matrix.map do |a|
        a + [nil] * (max_length - a.length)
      end
      matrix.transpose
    end

  end
end

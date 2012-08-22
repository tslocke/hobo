module HoboJqueryHelper
  def data_rapid(tag, options = {}, attributes = {})
    if attributes['data_rapid']
      hash = ActiveSupport::JSON.decode(attributes['data_rapid'])
    else
      hash = {}
    end
    hash[tag] = options
    hash.to_json
  end
end

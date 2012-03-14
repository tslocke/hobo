module HoboJqueryHelper
  def data_rapid(tag, options = {})
    {tag => options}.to_json
  end
end

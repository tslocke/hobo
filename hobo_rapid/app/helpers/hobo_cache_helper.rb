module HoboCacheHelper
  def hobo_cache_key(namespace=:views, route_on=nil, query_params=nil, attributes=nil)
    attributes ||= {}

    if route_on == true
      route_on = this
    end

    if route_on.is_a?(ActiveRecord::Base)
      route_on = url_for(route_on)
    end

    if route_on
      attributes.reverse_merge!(Rails.application.routes.recognize_path(route_on))
    elsif params[:page_path]
      # it's quite possible that our page was rendered by a different action, so normalize
      attributes.reverse_merge!(Rails.application.routes.recognize_path(params[:page_path]))
    end

    key_attrs = attributes
    key_attrs[:only_path] = false
    comma_split(query_params || "").each do |qp|
      key_attrs["#{qp}"] = params[qp] || ""
    end

    key = ActiveSupport::Cache.expand_cache_key(url_for(key_attrs).split('://').last, namespace)
    Digest::MD5.hexdigest(key)
  end

  def item_cache(*args, &block)
    unless Rails.configuration.action_controller.perform_caching
      yield if block_given?
    else
      key = hobo_cache_key(:item, *args)
      Rails.cache.fetch(key, &block)
    end
  end
end

module Hobo
  module Controller
    module Cache
      def expire_swept_caches_for(obj, attr=nil)
        typed_id = if attr.nil?
                     if obj.respond_to?(:typed_id)
                       obj.typed_id
                     else
                       obj.to_s
                     end
                   else
                     "#{obj.typed_id}:#{attr}"
                   end
        sweep_key = ActiveSupport::Cache.expand_cache_key(typed_id, :sweep_key)
        if Hobo.stable_cache.respond_to?(:read_matched)
          Hobo.stable_cache.read_matched(/#{sweep_key}/).each do |k,v|
            key=k[sweep_key.length+1..-1]
            Rails.logger.debug "CACHE DELETING #{key}"
            Rails.cache.delete(key)
            Hobo.stable_cache.delete(k)
          end
        else
          keys = Hobo.stable_cache.read(sweep_key)
          return if keys.nil? || keys.empty?
          keys.each do |key|
            Rails.logger.debug "CACHE DELETING #{key}"
            Rails.cache.delete(key)
          end
          Hobo.stable_cache.delete(sweep_key)
        end
      end

    end
  end
end

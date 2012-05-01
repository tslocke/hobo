module ActiveSupport
  module Cache
    class FileStore
      def hobo_read_matched(matcher, options = nil)
        Enumerator.new do |y|
          options = merged_options(options)
          matcher = key_matcher(matcher, options)
          search_dir(cache_path) do |path|
            key = file_path_key(path)
            y << [key, read_entry(key, options)] if key.match(matcher)
          end
        end
      end

      alias_method(:read_matched, :hobo_read_matched) unless method_defined?(:read_matched)
    end
  end
end

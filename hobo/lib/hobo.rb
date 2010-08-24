# gem dependencies
require 'hobo_support'
require 'hobo_fields'
require 'hobo/features/enumerable'
require 'hobo/features/array'

begin
  require 'will_paginate'
rescue MissingSourceFile
  # OK, Hobo won't do pagination then
end

ActiveSupport::Dependencies.autoload_paths |= [ File.dirname(__FILE__)]

# Hobo can be installed in /vendor/hobo, /vendor/plugins/hobo, vendor/plugins/hobo/hobo, etc.
::HOBO_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

class HoboError < RuntimeError; end

module Hobo

  VERSION = "1.3.0.pre2"

  class PermissionDeniedError < RuntimeError; end

  class RawJs < String; end

  class << self

    attr_accessor :current_theme

    def raw_js(s)
      RawJs.new(s)
    end

    def find_by_search(query, search_targets=[])
      if search_targets.empty?
       search_targets = Hobo::Routes.models_with(:show).select {|m| m.search_columns.any? }
      end

      query_words = ActiveRecord::Base.connection.quote_string(query).split

      search_targets.build_hash do |search_target|
        conditions = []
        parameters = []
        like_operator = ActiveRecord::Base.connection.adapter_name =~ /postgres/i ? 'ILIKE' : 'LIKE'
        query_words.each do |word|
          column_queries = search_target.search_columns.map { |column| "#{column} #{like_operator} ?" }
          conditions << "(" + column_queries.join(" or ") + ")"
          parameters.concat(["%#{word}%"] * column_queries.length)
        end
        conditions = conditions.join(" and ")

        results = search_target.find(:all, :conditions => [conditions, *parameters])
        [search_target.name, results] unless results.empty?
      end
    end

    def simple_has_many_association?(array_or_reflection)
      refl = array_or_reflection.respond_to?(:proxy_reflection) ? array_or_reflection.proxy_reflection : array_or_reflection
      return false unless refl.is_a?(ActiveRecord::Reflection::AssociationReflection)
      refl.macro == :has_many and
        (not refl.through_reflection) and
        (not refl.options[:conditions])
    end

    def subsites
      # Any directory inside app/controllers defines a subsite
      @subsites ||= Dir["#{Rails.root}/app/controllers/*"].map do |f|
                      File.basename(f) if File.directory?(f)
                    end.compact
    end

  end

  # Empty class to represent the boolean type.
  class Boolean; end

end

require 'hobo/engine'






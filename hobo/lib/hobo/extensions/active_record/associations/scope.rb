# Add support for :scope => :my_scope to associations

module ActiveRecord
  module Associations
    module ThroughAssociationScope

      def construct_scope_with_scope
        s = construct_scope_without_scope
        s[:find][:scope] = @reflection.options[:scope]
        s
      end
      alias_method_chain :construct_scope, :scope

      end
    end

  module SpawnMethods

    def apply_finder_options_with_scope(options)
      scopes = []
      Array.wrap(options.delete(:scope)).each do |s|
        if s.is_a?(Hash)
          s.each_pair{|k,v| scopes << [k,v] }
        else
          scopes << [s]
        end
      end
      relation = apply_finder_options_without_scope(options)
      return relation if scopes.empty?
      scopes.inject(relation) {|r, s| r.send *s }
    end
    alias_method_chain :apply_finder_options, :scope

  end
end

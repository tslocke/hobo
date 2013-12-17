# Add support for :scope => :my_scope to associations

module ActiveRecord
  module Associations
    module ThroughAssociationScope # No such module in ActiveRecord any more - there is only ThroughAssociation

      def construct_scope_with_scope
        s = construct_scope_without_scope
        s[:find][:scope] = @reflection.options[:scope]
        s
      end
      alias_method_chain :construct_scope, :scope

      end
    end if false # DISABLED Getting Rails 3.1 working

 class Relation
  module DeprecatedMethods

    def apply_finder_options_with_scope(options, silence_deprecation = false)
      scopes = []
      Array.wrap(options.delete(:scope)).each do |s|
        if s.is_a?(Hash)
          s.each_pair{|k,v| scopes << [k,v] }
        else
          scopes << [s]
        end
      end
      relation = apply_finder_options_without_scope(options, silence_deprecation)
      return relation if scopes.empty?
      scopes.inject(relation) {|r, s| r.send *s }
    end
    alias_method_chain :apply_finder_options, :scope
  end if false # DISABLED Getting Rails 4.0 working
 end
end

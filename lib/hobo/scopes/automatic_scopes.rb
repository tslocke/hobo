module Hobo
  
  module Scopes
    
    module AutomaticScopes
      
      def create_automatic_scope(name)
        ScopeBuilder.new(self, name).create_scope
      end
      
    end
    
    # The methods on this module add scopes to the given class
    class ScopeBuilder
      
      def initialize(klass, name)
        @klass = klass
        @name  = name.to_s
      end
      
      attr_reader :name
      
      def create_scope
        matched_scope = true
        
        # with_player(a_player)
        if name =~ /^with_(.*)/ && (refl = reflection($1.pluralize))
          
          def_scope do |record|
            { :include => refl.name, :conditions => ["#{primary_key_column refl} = ?", record] }
          end
          
        # with_players(player1, player2)
        elsif name =~ /^with_(.*)/ && (refl = reflection($1))
          
          def_scope do |*records|
            records = records.flatten
            { :include => refl.name, :conditions => ["#{primary_key_column refl} in (?)", records] }
          end
          

        # without_player(a_player)
        elsif name =~ /^without_(.*)/ && (refl = reflection($1.pluralize))

          def_scope do |record|
            { :include => refl.name, :conditions => ["#{primary_key_column refl} <> ?", record] }
          end
          
        # without_players(player1, player2)
        elsif name =~ /^with_(.*)/ && (refl = reflection($1))
          
          def_scope do |*records|
            records = records.flatten
            { :include => refl.name, :conditions => ["#{primary_key_column refl} not in (?)", records] }
          end
          
        elsif name =~ /^(.*)_is$/ && (refl = reflection($1))
          
          if refl.options[:polymorphic]
            def_scope do |record|
              { :conditions => ["#{foreign_key_column refl} = ? AND #{$1}_type = ?", record, record.class.name] }
            end
          else
            def_scope do |record|
              { :conditions => ["#{foreign_key_column refl} = ?", record] }
            end
          end
            
        elsif name =~ /^(.*)_is_not$/ && (refl = reflection($1))
          
          if refl.options[:polymorphic]
            def_scope do |record|
              { :conditions => ["#{foreign_key_column refl} <> ? OR #{name}_type <> ?", record.id, record.class.name] }
            end
          else
            def_scope do |record|
              { :conditions => ["#{foreign_key_column refl} <> ?", record.id] }
            end
          end

        else
          matched_scope = false
        end
        matched_scope
      end
      
      
      def reflection(name)
        @klass.reflections[name.to_sym]
      end
      
      def def_scope(options={}, &block)
        @klass.send(:def_scope, name, options, &block)
      end
      
      
      
      
      def with_association(klass, refl)
      end
      
      def without_association(klass, refl)
      end

      def primary_key_column(refl)
        "#{refl.klass.table_name}.#{refl.klass.primary_key}"
      end
      
      def foreign_key_column(refl)
        "#{@klass.table_name}.#{refl.primary_key_name}"
      end
      
    end
    
  end
  
end

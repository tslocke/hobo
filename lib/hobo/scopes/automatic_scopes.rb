module Hobo
  
  module Scopes
    
    module AutomaticScopes
      
      def create_automatic_scope(name)
        ScopeBuilder.new(self, name).create_scope
      rescue ActiveRecord::StatementInvalid
        # Problem with the database? Don't try to create automatic scopes
        false
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
        
        
        # --- Association Queries --- #
        
        # with_players(player1, player2)
        if name =~ /^with_(.*)/ && (refl = reflection($1))
          
          def_scope do |*records|
            records = records.flatten.compact.map {|r| find_if_named(refl, r) }
            exists_sql = ([exists_sql_condition(refl)] * records.length).join(" AND ")
            { :conditions => [exists_sql] + records }
          end

        # with_player(a_player)
        elsif name =~ /^with_(.*)/ && (refl = reflection($1.pluralize))
          
          exists_sql = exists_sql_condition(refl)
          def_scope do |record|
            record = find_if_named(refl, record)
            { :conditions => [exists_sql, record] }
          end
          
        # without_players(player1, player2)
        elsif name =~ /^without_(.*)/ && (refl = reflection($1))
          
          def_scope do |*records|
            records = records.flatten.compact.map {|r| find_if_named(refl, r) }
            exists_sql = ([exists_sql_condition(refl)] * records.length).join(" AND ")
            { :conditions => ["NOT (#{exists_sql})"] + records }
          end

        # without_player(a_player)
        elsif name =~ /^without_(.*)/ && (refl = reflection($1.pluralize))
          
          exists_sql = exists_sql_condition(refl)
          def_scope do |record|
            record = find_if_named(refl, record)
            { :conditions => ["NOT #{exists_sql}", record] }
          end

        # team_is(a_team)
        elsif name =~ /^(.*)_is$/ && (refl = reflection($1)) && refl.macro.in?([:has_one, :belongs_to])
          
          if refl.options[:polymorphic]
            def_scope do |record|
              record = find_if_named(refl, record)
              { :conditions => ["#{foreign_key_column refl} = ? AND #{$1}_type = ?", record, record.class.name] }
            end
          else
            def_scope do |record|
              record = find_if_named(refl, record)
              { :conditions => ["#{foreign_key_column refl} = ?", record] }
            end
          end
            
        # team_is(a_team)
        elsif name =~ /^(.*)_is_not$/ && (refl = reflection($1)) && refl.macro.in?([:has_one, :belongs_to])
          
          if refl.options[:polymorphic]
            def_scope do |record|
              record = find_if_named(refl, record)
              { :conditions => ["#{foreign_key_column refl} <> ? OR #{name}_type <> ?", record, record.class.name] }
            end
          else
            def_scope do |record|
              record = find_if_named(refl, record)
              { :conditions => ["#{foreign_key_column refl} <> ?", record] }
            end
          end
          
        
        # --- Column Queries --- #
          
        # name_is(str)
        elsif name =~ /^(.*)_is$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} = ?", str] }
          end
          
        # name_is_not(str)
        elsif name =~ /^(.*)_is_not$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} <> ?", str] }
          end
          
        # name_contains(str)
        elsif name =~ /^(.*)_contains$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} LIKE ?", "%#{str}%"] }
          end
          
        # name_does_not_contain
        elsif name =~ /^(.*)_does_not_contain$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} NOT LIKE ?", "%#{str}%"] }
          end
          
        # name_starts(str)
        elsif name =~ /^(.*)_contains$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} LIKE ?", "#{str}%"] }
          end
          
        # name_does_not_start
        elsif name =~ /^(.*)_does_not_contain$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} NOT LIKE ?", "#{str}%"] }
          end
          
        # name_ends(str)
        elsif name =~ /^(.*)_contains$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} LIKE ?", "%#{str}"] }
          end
          
        # name_does_not_end(str)
        elsif name =~ /^(.*)_does_not_contain$/ && (col = column($1))

          def_scope do |str|
            { :conditions => ["#{column_sql(col)} NOT LIKE ?", "%#{str}"] }
          end
          
        # published
        elsif (col = column(name)) && (col.type == :boolean)

          def_scope do 
            { :conditions => ["#{column_sql(col)} = ?", true] }
          end
        
        # not_published
        elsif name =~ /^not_(.*)$/ && (col = column($1)) && (col.type == :boolean)

          def_scope do 
            { :conditions => ["#{column_sql(col)} <> ?", true] }
          end
          
        # published_before(time)
        elsif name =~ /^(.*)_before$/ && (col = column("#{$1}_at")) && col.type.in?([:date, :datetime, :time, :timestamp])

          def_scope do |time|
            { :conditions => ["#{column_sql(col)} < ?", time] }
          end
        
        # published_after(time)
        elsif name =~ /^(.*)_after$/ && (col = column("#{$1}_at")) && col.type.in?([:date, :datetime, :time, :timestamp])

          def_scope do |time|
            { :conditions => ["#{column_sql(col)} > ?", time] }
          end

        # published_between(time1, time2)
        elsif name =~ /^(.*)_between$/ && (col = column("#{$1}_at")) && col.type.in?([:date, :datetime, :time, :timestamp])

          def_scope do |time1, time2|
            { :conditions => ["#{column_sql(col)} >= ? AND #{column_sql(col)} =< ?", time1, time2] }
          end
          
         # active (a lifecycle state)
        elsif @klass.has_lifecycle? && name.in?(@klass::Lifecycle.state_names)

          def_scope do 
            { :conditions => ["#{@klass.table_name}.#{@klass::Lifecycle.state_field} = ?", name] }
          end

        else
        
          case name
            
          when "recent"
            def_scope do |*args|
              count = args.first || 3
              { :limit => count, :order => "#{@klass.table_name}.created_at DESC" }
            end
            
          when "limit"
            def_scope do |count|
              { :limit => count }
            end

          when "order_by"
            klass = @klass
            def_scope do |*args|
              field, asc = args
              type = klass.attr_type(field)
              if type.respond_to?(:table_name) && (name = type.name_attribute)
                include = field
                colspec = "#{type.table_name}.#{name}"
              else
                colspec = "#{klass.table_name}.#{field}"
              end
              { :order => "#{colspec} #{asc._?.upcase}", :include => include }
            end
            

          when "include"
            def_scope do |inclusions|
              { :include => inclusions }
            end
            
          when "search"
            def_scope do |query, *fields|
              words = query.split
              args = []              
              word_queries = words.map do |word|
                field_query = '(' + fields.map { |field| "(#{@klass.table_name}.#{field} like ?)" }.join(" OR ") + ')'
                args += ["%#{word}%"] * fields.length
                field_query
              end
              
              { :conditions => [word_queries.join(" AND ")] + args }
            end
            
          else
            matched_scope = false
          end
          
        end
        matched_scope
      end
      
      
      def column_sql(column)
        "#{@klass.table_name}.#{column.name}"
      end
      
      
      def exists_sql_condition(reflection)
        owner = @klass
        owner_primary_key = "#{owner.table_name}.#{owner.primary_key}"
        if reflection.options[:through]
          join_table   = reflection.through_reflection.klass.table_name
          source_fkey  = reflection.source_reflection.primary_key_name
          owner_fkey   = reflection.through_reflection.primary_key_name
          "EXISTS (SELECT * FROM #{join_table} " + 
            "WHERE #{join_table}.#{source_fkey} = ? AND #{join_table}.#{owner_fkey} = #{owner_primary_key})"
        else
          related     = reflection.klass
          foreign_key = reflection.primary_key_name
          
          "EXISTS (SELECT * FROM #{related.table_name} " + 
            "WHERE #{related.table_name}.#{foreign_key} = #{owner_primary_key} AND " +
            "#{related.table_name}.#{related.primary_key} = ?)"
        end
      end
              
      
      def find_if_named(reflection, string_or_record)
        if string_or_record.is_a?(String)
          name = string_or_record
          reflection.klass.named(name)
        else
          string_or_record
        end
      end
      
      
      def column(name)
        @klass.column(name)
      end
      
      
      def reflection(name)
        @klass.reflections[name.to_sym]
      end
      
      
      def def_scope(options={}, &block)
        @klass.send(:def_scope, name, options, &block)
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

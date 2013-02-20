require 'searchtastic/version'
require 'chronic'

# This module is automatically included in all ActiveRecords
module Searchtastic
  module ActiveRecord

    # Array of fields upon which it's possible to search
    def fields
      @fields || []
    end

    # Sets the searchable fields for a given model
    #   class User < ActiveRecord::Base
    #     search_fields %w(name email bio)
    #   end
    #
    def searchable_by *fields
        self.fields = process_fields(fields)
    end

    # Called on an ActiveRelation containing the model
    #
    #   filter = "Pete"
    #   @filtered_models = User.search(filter)
    #
    def search filter
      if filter && is_searchable?
        filter = [filter, Chronic.parse(filter).strftime("%Y-%m-%d")] rescue filter
        handle_joins(self.fields, scoped.select("DISTINCT(`#{self.table_name}`.`id`), `#{self.table_name}`.*"))
        .where(build_filter(filter, self.fields))
      else
        scoped
      end
    end

    # Callable on an instance or the call itself to detect whether .search() will have meaningful results
    #
    #     User.search(@filter) if User.is_searchable?
    #
    def is_searchable?
      self.fields.count > 0
    end

    private

    # Set fields -- private, see searchable_by
    def fields=(value)
      @fields = value
    end

    # Fields can be specified with or without the model table name, but internally all
    # fields need to be qualified by table name for disambiguation
    #
    #     fields = %w(name email)
    #     process_fields(fields) => %w(users.name users.email)
    #
    def process_fields(fields)
        fields.map { |field| field.to_s.include?('.') ? field.to_s : "#{self.table_name}.#{field}" }
    end

    # Before adding the where clauses, we have to make sure the right tables are joined
    # into the query. We use .includes() instead of .joins() so we can get an OUTER JOIN
    #
    def handle_joins fields, select = nil
      ret = select || scoped
      fields.each do |qualified_field|
        assoc, foreign_table, field = parse_field(qualified_field)
        ret = ret.joins(join_string(assoc, foreign_table)) if assoc
      end
      ret
    end

    def join_string(assoc, foreign_table)
      reflection = self.reflect_on_association(assoc.to_sym)
      case reflection.macro
        when :belongs_to
          "LEFT OUTER JOIN `#{foreign_table}` on `#{foreign_table}`.`id` = `#{self.table_name}`.`#{assoc.singularize}_id`"
        when :has_one
          if reflection.options.has_key?(:through)
            "LEFT OUTER JOIN `#{reflection.options[:through].pluralize}` on `#{reflection.options[:through].pluralize}`.`id` = `#{self.table_name}`.`#{reflection.options[:through]}_id` "+
            "LEFT OUTER JOIN `#{foreign_table}` on `#{foreign_table}`.`id` = `#{reflection.options[:through].pluralize}`.`#{assoc.singularize}_id`"
          else
            "LEFT OUTER JOIN `#{foreign_table}` on `#{foreign_table}`.`id` = `#{self.table_name}`.`#{assoc.singularize}_id`"
          end
        when :has_many
          "LEFT OUTER JOIN `#{foreign_table}` on `#{self.table_name}`.`id` = `#{foreign_table}`.`#{self.table_name.singularize}_id`"
        #when :has_and_belongs_to_many
        else
          raise "Searching against HABTM associations is not supported"
      end
    end

    # Get table name from association name
    #
    #   class User < ActiveRecord::Base
    #     belongs_to :company, class_name: Organization
    #     searchable_by :name, :email, :'company.name'
    #   end
    #
    #   parse_field('company.name') => ['companies', 'organizations', 'name']
    #
    def parse_field(qualified_field)
      if qualified_field.include? '.'
        assoc, field = qualified_field.split('.')
        if assoc != self.table_name
          return assoc, self.reflect_on_association(assoc.to_sym).table_name, field
        end
      end

      return nil, self.table_name, field

    end

    # Build the filter for the .where() clause in the search method
    #
    def build_filter filters, fields
      filters = [filters] unless filters.is_a? Array
      where = [Array.new(filters.count, associations_to_tables(fields).map { |f| "#{f} LIKE ?" }.join(" || ")).join(" || ")]
      filters.each do |filter|
        fields.count.times { |n| where << "%#{filter}%" }
      end
      where
    end

    # Set the field to the right table and column name for the database
    #
    def associations_to_tables fields
      fields.map do |field|
        _, column = field.split('.')
        "#{parse_field(field)[1]}.#{column}"
      end
    end

  end #ActiveRecord
end #Searchtastic

ActiveRecord::Base.extend Searchtastic::ActiveRecord
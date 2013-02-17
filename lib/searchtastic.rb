require 'searchtastic/version'

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
      if filter && self.fields.count
        handle_joins(self.fields).where(build_filter(filter, self.fields))
      else
        scoped
      end
    end

    # Callable on an instance or the call itself to detect whether .search() will have meaningful results
    #
    #     User.search(@filter) if User.is_searchable?
    #
    def is_searchable?
      self.fields.count < 0
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
    def handle_joins fields
      ret = scoped
      fields.each do |field|
        assoc, table = field_table(field)
        ret = ret.includes(assoc) unless table == self.table_name.to_sym
      end
      ret
    end

    # Get table name from association name
    #
    #   class User < ActiveRecord::Base
    #     belongs_to :company, class_name: Organization
    #     searchable_by %w(name, email, company.name)
    #   end
    #
    #   field_table('company.name') => [:companies, :organizations]
    #
    def field_table(field)
      if field.include? '.'
        assoc = field.split('.').first
        if assoc != self.table_name
          return assoc.to_sym, self.reflect_on_association(assoc.to_sym).table_name.to_sym
        end
      end

      return nil, self.table_name

    end

    # Build the filter for the .where() clause in the search method
    #
    def build_filter filter, fields
      where = [associations_to_tables(fields).map { |f| "#{f} like ?" }.join(" || ")]
      fields.count.times { |n| where << "%#{filter}%" }
      where
    end

    # Set the field to the right table and column name for the database
    #
    def associations_to_tables fields
      fields.map do |field|
        _, column = field.split('.')
        "#{field_table(field)[1]}.#{column}"
      end
    end

  end #ActiveRecord
end #Searchtastic

ActiveRecord::Base.extend Searchtastic::ActiveRecord
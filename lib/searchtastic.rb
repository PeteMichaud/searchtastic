require 'searchtastic/version'

module Searchtastic
  module ActiveRecord
      def fields
        @fields || []
      end

      def fields=(value)
        @fields = value
      end

      def search_fields fields
        self.fields = process_fields(fields)
      end

      def search filter
        if filter && self.fields.count
          handle_joins(self.fields).where(build_filter(filter, self.fields))
        else
          scoped
        end
      end

      def is_searchable?
        true
      end

      private

      def process_fields(fields)
        fields.map { |field| field.include?('.') ? field : "#{self.table_name}.#{field}" }
      end

      def handle_joins fields
        ret = scoped
        fields.each do |field|
          assoc, table = field_table(field)
          ret = ret.includes(assoc) unless table == self.table_name.to_sym
        end
        ret
      end

      def field_table(field)
        if field.include? '.'
          assoc = field.split('.').first
          if assoc != self.table_name
            return assoc.to_sym, self.reflect_on_association(assoc.to_sym).table_name.to_sym
          end
        end

        return nil, self.table_name

      end

      # build the filter for the .where clause in the search method
      def build_filter filter, fields
        where = [associations_to_tables(fields).map { |f| "#{f} like ?" }.join(" || ")]
        fields.count.times { |n| where << "%#{filter}%" }
        where
      end

      def associations_to_tables fields
        fields.map do |field|
          _, column = field.split('.')
          "#{field_table(field)[1]}.#{column}"
        end
      end

  end #ActiveRecord
end #Searchtastic

ActiveRecord::Base.extend Searchtastic::ActiveRecord
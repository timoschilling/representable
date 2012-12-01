require 'representable/hash'
require 'csv'

module Representable
  # Brings #to_csv and #from_csv to your object.
  module CSV
    extend Hash::ClassMethods
    include Hash

    def self.included(base)
      base.class_eval do
        include Representable # either in Hero or HeroRepresentation.
        extend ClassMethods # DISCUSS: do that only for classes?
        extend Representable::Hash::ClassMethods  # DISCUSS: this is only for .from_hash, remove in 2.3?
      end
    end

    module ClassMethods
      # Creates a new object from the passed CSV document.
      def from_csv(*args, &block)
        create_represented(*args, &block).from_csv(*args)
      end
    end

    # Parses the body as CSV and delegates to #from_hash.
    def from_csv(csv_string, *args)
      keys, values = ::CSV.parse(csv_string)
      data = {}
      keys.each_with_index do |key, i|
        data[key] = values[i]
      end
      from_hash(data, *args)
    end

    # Returns a CSV string representing this object.
    def to_csv(*args)
      ::CSV.generate do |csv|
        csv << cols = representable_attrs.map(&:name)
        csv << to_hash(*args).values_at(*cols)
      end
    end
  end
end

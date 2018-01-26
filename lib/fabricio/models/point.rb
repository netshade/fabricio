require 'date'

module Fabricio
  module Model
    # This model represents a data point with two fields - timestamp and value
    class Point
      attr_reader :date, :value

      # Returns a data point with two fields - timestamp and value
      #
      # @param attributes [Hash]
      # @return [Fabricio::Model::Point]
      def initialize(attributes)
        @date = DateTime.strptime(attributes.first.to_s,'%s')
        @value = attributes.last
      end
     
      def as_json(*)
        [@date.to_time.to_i, @value]
      end
     
      def to_json(*)
        as_json.to_json
      end
    end
  end
end

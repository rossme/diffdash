# frozen_string_literal: true

module Diffdash
  module Engine
    # Represents an intent to observe a signal, not vendor syntax.
    # Example: logs for service X during time window Y.
    class SignalQuery
      attr_reader :type, :name, :filters, :time_range, :metadata,
                  :source_file, :defining_class

      def initialize(type:, name:, filters: {}, time_range: nil, metadata: {},
                     source_file: nil, defining_class: nil)
        @type = type
        @name = name
        @filters = filters
        @time_range = time_range
        @metadata = metadata
        @source_file = source_file
        @defining_class = defining_class
      end

      def logs?
        type == :logs
      end

      def metrics?
        type == :metrics
      end

      def to_h
        {
          type: type,
          name: name,
          filters: filters,
          time_range: time_range,
          metadata: metadata,
          source_file: source_file,
          defining_class: defining_class
        }
      end
    end
  end
end

# frozen_string_literal: true

module Diffdash
  module Engine
    # Vendor-agnostic core engine.
    # Produces structured signal intent from diff context.
    class Engine
      DEFAULT_TIME_RANGE = { from: "now-1h", to: "now" }.freeze

      attr_reader :dynamic_metrics

      def initialize(config:)
        @config = config
        @collector = Services::SignalCollector.new
        @dynamic_metrics = []
      end

      def run(change_set: ChangeSet.from_git, time_range: DEFAULT_TIME_RANGE)
        signals = @collector.collect(change_set.filtered_files)
        @dynamic_metrics = @collector.dynamic_metrics

        validate_limits!(signals)

        bundle = SignalBundle.new(
          logs: build_queries(signals, :logs, time_range),
          metrics: build_queries(signals, :metrics, time_range),
          traces: [],
          metadata: {
            change_set: change_set.to_h,
            time_range: time_range,
            dynamic_metrics: @dynamic_metrics
          }
        )

        bundle
      end

      private

      def build_queries(signals, type, time_range)
        signals.filter_map do |signal|
          query = Signal.from_domain(signal, time_range: time_range)
          query if query&.type == type
        end
      end

      def validate_limits!(signals)
        validator = Validation::Limits.new(@config)
        validator.validate!(signals)
      end
    end
  end
end

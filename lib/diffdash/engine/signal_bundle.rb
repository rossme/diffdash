# frozen_string_literal: true

module Diffdash
  module Engine
    # Container for signals returned by the engine.
    # Keeps engine output serialisable and side-effect free.
    class SignalBundle
      attr_reader :logs, :metrics, :endpoints, :traces, :metadata

      def initialize(logs: [], metrics: [], endpoints: [], traces: [], metadata: {})
        @logs = logs
        @metrics = metrics
        @endpoints = endpoints
        @traces = traces
        @metadata = metadata
      end

      def empty?
        logs.empty? && metrics.empty? && endpoints.empty? && traces.empty?
      end

      def to_h
        {
          logs: logs.map(&:to_h),
          metrics: metrics.map(&:to_h),
          endpoints: endpoints.map(&:to_h),
          traces: traces.map(&:to_h),
          metadata: metadata
        }
      end
    end
  end
end

# frozen_string_literal: true

module Diffdash
  module Renderers
    # Backwards-compatible wrapper.
    # Use Outputs::Grafana for new integrations.
    class Grafana
      def initialize(signals:, title:, folder_id: nil)
        @signals = signals
        @title = title
        @folder_id = folder_id
      end

      def render
        bundle = Engine::SignalBundle.new(
          logs: build_queries(@signals, :logs),
          metrics: build_queries(@signals, :metrics),
          traces: [],
          metadata: { time_range: { from: "now-1h", to: "now" } }
        )

        Outputs::Grafana.new(title: @title, folder_id: @folder_id).render(bundle)
      end

      private

      def build_queries(signals, type)
        signals.filter_map do |signal|
          query = Engine::Signal.from_domain(signal, time_range: { from: "now-1h", to: "now" })
          query if query&.type == type
        end
      end
    end
  end
end

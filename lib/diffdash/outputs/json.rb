# frozen_string_literal: true

module Diffdash
  module Outputs
    # Simple JSON output adapter for SignalBundle.
    class Json < Base
      def render(signal_bundle)
        signal_bundle.to_h
      end
    end
  end
end

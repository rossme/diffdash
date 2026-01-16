# frozen_string_literal: true

module Diffdash
  module Outputs
    # Placeholder adapter for future Kibana support.
    class Kibana < Base
      def render(_signal_bundle)
        raise NotImplementedError, "Kibana output adapter is not implemented yet"
      end
    end
  end
end

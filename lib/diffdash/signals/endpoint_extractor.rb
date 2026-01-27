# frozen_string_literal: true

require_relative "../signal/endpoint"

module Diffdash
  module Signals
    # Extracts endpoint signals from the AST visitor
    class EndpointExtractor
      class << self
        def extract(visitor)
          visitor.endpoint_calls.filter_map do |endpoint_call|
            Diffdash::Signal::Endpoint.new(
              name: endpoint_call[:name],
              source_file: visitor.file_path,
              defining_class: endpoint_call[:defining_class],
              inheritance_depth: visitor.inheritance_depth,
              metadata: {
                action_name: endpoint_call[:action_name],
                http_method: endpoint_call[:http_method],
                route_path: endpoint_call[:route_path],
                endpoint_type: endpoint_call[:endpoint_type],
                line: endpoint_call[:line]
              }
            )
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative "base"

module Diffdash
  module Signal
    # Represents a detected HTTP endpoint (Rails controller action, Grape/Sinatra route)
    #
    # Endpoints are controller actions or API routes that handle HTTP requests.
    # The dashboard will show request rate, latency, and error rate for these endpoints.
    class Endpoint < Base
      def initialize(
        name:,
        source_file:,
        defining_class:,
        inheritance_depth:,
        metadata: {}
      )
        super(
          name: name,
          type: :endpoint,
          source_file: source_file,
          defining_class: defining_class,
          inheritance_depth: inheritance_depth,
          metadata: metadata
        )
      end

      def endpoint?
        true
      end

      # HTTP method (GET, POST, PUT, PATCH, DELETE)
      def http_method
        metadata[:http_method]&.upcase || "GET"
      end

      # Route path if available (e.g., "/users/:id")
      def route_path
        metadata[:route_path]
      end

      # Controller action name (e.g., "show", "create")
      def action_name
        metadata[:action_name]
      end

      # Controller name (e.g., "UsersController")
      def controller_name
        defining_class
      end

      def line
        metadata[:line]
      end

      # Returns a descriptive label for the endpoint
      # e.g., "UsersController#show" or "GET /api/users"
      def label
        if route_path
          "#{http_method} #{route_path}"
        elsif action_name
          "#{defining_class}##{action_name}"
        else
          name
        end
      end
    end
  end
end

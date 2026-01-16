# frozen_string_literal: true

module Diffdash
  # Backwards-compatible CLI entrypoint.
  module CLI
    def self.run(args)
      Diffdash::CLI::Runner.run(args)
    end
  end
end

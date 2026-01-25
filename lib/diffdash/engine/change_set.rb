# frozen_string_literal: true

module Diffdash
  module Engine
    # Represents the set of changes to analyze.
    # Keeps diff context and file filtering in the engine layer.
    class ChangeSet
      attr_reader :branch_name, :changed_files, :filtered_files

      def initialize(branch_name:, changed_files:, filtered_files:)
        @branch_name = branch_name
        @changed_files = changed_files
        @filtered_files = filtered_files
      end

      # Create a ChangeSet from git context.
      #
      # @param config [Config, nil] optional config for file filtering rules
      def self.from_git(config: nil)
        git_context = GitContext.new
        changed_files = git_context.changed_files
        file_filter = FileFilter.new(config: config)
        filtered_files = file_filter.filter(changed_files)

        new(
          branch_name: git_context.branch_name,
          changed_files: changed_files,
          filtered_files: filtered_files
        )
      end

      def to_h
        {
          branch_name: branch_name,
          changed_files: changed_files,
          filtered_files: filtered_files
        }
      end
    end
  end
end

# encoding: utf-8

module Backup
  module Executor
    class Error < Backup::Error; end

    class Base
      include Utilities::Helpers
      include Config::Helpers

      attr_reader :model, :executor_id

      ##
      # +executor_id+ is a user-defined string used to uniquely identify
      # multiple executors of the same type. If multiple executors of the same
      # type are added to a single backup model, this identifier must be set.
      def initialize(model, executor_id = nil)
        @model = model
        @executor_id = executor_id.to_s.gsub(/\W/, '_') if executor_id
        load_defaults!
      end

      def perform!
        log!(:started)
      end

      private

      def executor_name
        @executor_name ||= self.class.to_s.sub('Backup::', '') +
            (executor_id ? " (#{ executor_id })" : '')
      end

      def log!(action)
        msg = case action
              when :started then 'Started...'
              when :finished then 'Finished!'
              end
        Logger.info "#{ executor_name } #{ msg }"
      end
    end
  end
end

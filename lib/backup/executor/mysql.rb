# encoding: utf-8

module Backup
  module Executor
    class MySQL < Base
      class Error < Backup::Error; end

      ##
      # Name of the database to execute command against
      attr_accessor :name

      ##
      # Credentials for the specified database
      attr_accessor :username, :password

      ##
      # Connectivity options
      attr_accessor :host, :port, :socket

      ##
      # Statement to execute
      attr_accessor :statement

      ##
      # Additional "mysql" options
      attr_accessor :additional_options

      def initialize(model, executor_id = nil, &block)
        super
        instance_eval(&block) if block_given?

        @name ||= :all
      end

      ##
      # Performs the mysql command.
      #
      def perform!
        super

        pipeline = Pipeline.new

        pipeline << mysql

        pipeline.run
        if pipeline.success?
          log!(:finished)
        else
          raise Error, "Execution Failed!\n" + pipeline.error_messages
        end
      end

      private

      def mysql
        "#{ utility(:mysql) } #{ credential_options } " +
        "#{ connectivity_options } #{ user_options } #{ execute_options } #{ name_option } "
      end

      def credential_options
        opts = []
        opts << "--user='#{ username }'" if username
        opts << "--password='#{ password }'" if password
        opts.join(' ')
      end

      def connectivity_options
        return "--socket='#{ socket }'" if socket

        opts = []
        opts << "--host='#{ host }'" if host
        opts << "--port='#{ port }'" if port
        opts.join(' ')
      end

      def user_options
        Array(additional_options).join(' ')
      end

      def execute_options
        "--execute='#{ statement }'"
      end

      def name_option
        name
      end

    end
  end
end

module Superlogger
  class ActiveRecordLogSubscriber < ActiveSupport::LogSubscriber
    IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN", "ActiveRecord::SchemaMigration Load"]

    def self.runtime=(value)
      ActiveRecord::RuntimeRegistry.sql_runtime = value
    end

    def self.runtime
      ActiveRecord::RuntimeRegistry.sql_runtime ||= 0
    end

    def sql(event)
      self.class.runtime += event.duration

      return unless Rails.application.config.superlogger.sql_enabled

      payload = event.payload
      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      sql = payload[:sql]
      params = payload[:binds].map { |_, value| value.to_s }

      logger.debug sql: sql, params: params, duration: event.duration.round(2)
    end
  end
end

Superlogger::ActiveRecordLogSubscriber.attach_to :active_record

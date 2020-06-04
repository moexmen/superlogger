require 'request_store'

module Superlogger
  class Logger < ActiveSupport::Logger
    def format_message(severity, time, _progname, msg)
      return nil if msg.blank? # Silence nil and empty msg
      return nil if is_rails_rack_logger_msg?(msg) # Silence rack logger msg

      msg = {msg: msg} unless msg.is_a?(Hash)

      h = {}
      h[:level] = severity.downcase
      h[:ts] = time.to_f
      h[:caller] = get_caller_location
      h[:session_id] = Superlogger.session_id[0..11] unless Superlogger.session_id.nil?
      h[:request_id] = Superlogger.request_id unless Superlogger.request_id.nil?
      h.merge!(msg)

      h.to_json + "\n"
    end

    def is_rails_rack_logger_msg?(msg)
      return false unless msg.is_a?(String)
      msg =~ /Started (GET|POST|PUT|PATCH|DELETE)/
    end

    def get_caller_location
      index = caller_locations(4, 1).first.label.include?('broadcast') ? 6 : 5
      location = caller_locations(index, 1).first

      # Extract filename without file extension from location.path
      # eg. superlogger/lib/superlogger/logger.rb => superlogger/logger
      file = location.path.split('/').last(2).join('/').split('.').first

      "#{file}:#{location.lineno}"
    end

    # To silence double logging when running `rails server` in development mode
    # See: https://github.com/rails/rails/commit/3d10d9d6c3b831fe9632c43a0ffec46104f912a7
    if Rails.env.development?
      class SimpleFormatter < ::Logger::Formatter
        def call(_severity, _timestamp, _progname, _msg)
          nil
        end
      end
    end
  end
end

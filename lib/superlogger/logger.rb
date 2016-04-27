require 'request_store'

module Superlogger
  class Logger < ActiveSupport::Logger
    def initialize(*args)
      super
      @formatter = SimpleFormatter.new
    end

    def format_message(severity, time, _progname, msg)
      return nil if msg.blank? # Silence nil and empty msg
      return nil if is_rails_rack_logger_msg?(msg) # Silence rack logger msg

      timestamp = time.strftime('%Y-%m-%d %H:%M:%S.%L')
      session_id = Superlogger.session_id[0..11]
      request_id = Superlogger.request_id[0..11]
      severity = severity.to_s.upcase[0]
      caller_location = get_caller_location
      args = format_args(msg)

      "#{timestamp} | #{session_id} | #{request_id} | #{severity} | #{caller_location} | #{args}\n"
    end

    def is_rails_rack_logger_msg?(msg)
      msg =~ /Started (GET|POST|PUT|PATCH|DELETE)/
    end

    def get_caller_location
      index = caller_locations(4, 1).first.label.include?('broadcast') ? 6 : 5
      location = caller_locations(index, 1).first

      # Extract filename without file extension from location.path
      # eg. superlogger/lib/superlogger/logger.rb
      file = location.path.split('/').last.split('.').first

      "#{file}:#{location.lineno}"
    end

    def format_args(args)
      output = if args.is_a?(Hash)
                 # Format args in key=value pair, separated by pipes
                 args.map do |key, value|
                   "#{key}=#{value}"
                 end.join(' | ')
               else
                 args.to_s
               end

      output.gsub("\n", '\\n') # Escape newlines
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

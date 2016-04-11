require 'request_store'

module Superlogger
  module Logger
    def self.session_id=(session_id)
      RequestStore.store[:superlogger_session_id] = session_id
    end

    def self.session_id
      RequestStore.store[:superlogger_session_id] || "NS-#{Thread.current.object_id}"
    end

    def self.debug(*args)
      Rails.logger.debug { format_msg(args) }
    end

    def self.info(*args)
      Rails.logger.info { format_msg(args) }
    end

    def self.warn(*args)
      Rails.logger.warn { format_msg(args) }
    end

    def self.error(*args)
      Rails.logger.error { format_msg(args) }
    end

    def self.fatal(*args)
      Rails.logger.fatal { format_msg(args) }
    end

    private

    def self.format_msg(args)
      "#{get_caller_location} | #{format_args(args)}"
    end

    def self.get_caller_location
      # Find the last method call on Superlogger::Logger
      count = 0
      location_index = caller_locations(0).find_index do |location|
        count += 1 if location && location.path.include?('superlogger/logger.rb')
        count == 4
      end

      # Add 1 to get the caller of the logger
      location = caller_locations(location_index + 1).first

      # extract filename without file extension from location.path
      # eg. superlogger/lib/superlogger/logger.rb
      file = location.path.split('/').last.split('.').first

      "#{file}:#{location.lineno}"
    end

    def self.format_args(args)
      # format args in key=value pair, separated by pipes
      args.map do |arg|
        arg = {nil: arg} unless arg.is_a?(Hash)

        arg.map do |key, value|
          "#{key}=#{value}"
        end
      end.flatten.join(' | ')
    end
  end
end

# for overriding default Rails Logger format
class Logger
  def format_message(severity, time, _progname, msg)
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S.%L')
    session_id = Superlogger::Logger.session_id[0..11]
    severity = severity.to_s.upcase[0]

    "#{timestamp} | #{session_id} | #{severity} | #{msg}\n"
  end
end

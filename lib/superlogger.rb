require 'superlogger/version'
require 'superlogger/logger'

module Superlogger
  module_function

  def setup(app)
    overwrite_rails_rack_logger
    overwrite_action_dispatch_debug_exceptions
    insert_superlogger_middleware(app)
    detach_all_existing_log_subscribers
    attach_superlogger_log_subscribers
  end

  def overwrite_rails_rack_logger
    require 'superlogger/rails_rack_logger'
  end

  def overwrite_action_dispatch_debug_exceptions
    require 'superlogger/action_dispatch_debug_exceptions'
  end

  def insert_superlogger_middleware(app)
    require 'superlogger/middleware'

    # important to insert after session middleware so we can get the session id
    app.middleware.use Superlogger::Middleware
  end

  def detach_all_existing_log_subscribers
    # force log subscribers to attach first so we can remove them all
    require 'action_controller/log_subscriber'
    require 'active_record/log_subscriber'
    require 'action_view/log_subscriber'
    require 'action_mailer/log_subscriber'

    # remove log subscribers
    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      subscriber.patterns.each do |pattern|
        ActiveSupport::Notifications.unsubscribe pattern
      end
    end

    ActiveSupport::LogSubscriber.log_subscribers.clear
  end

  def attach_superlogger_log_subscribers
    require 'superlogger/action_controller_log_subscriber'
    require 'superlogger/action_view_log_subscriber'
    require 'superlogger/active_record_log_subscriber'
  end
end

require 'superlogger/railtie' if defined?(Rails)

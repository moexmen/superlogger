require 'superlogger/version'
require 'superlogger/logger'

module Superlogger
  module_function

  def setup(app)
    insert_superlogger_middleware(app)
    detach_existing_log_subscribers
    attach_superlogger_log_subscribers
  end

  def insert_superlogger_middleware(app)
    require 'superlogger/superlogger_middleware'

    # important to insert after session middleware so we can get the session id
    app.middleware.use Superlogger::SuperloggerMiddleware
  end

  def detach_existing_log_subscribers
    # force log subscribers to attach first so we can remove them all
    require 'action_controller/log_subscriber'
    require 'active_record/log_subscriber'
    require 'action_view/log_subscriber'

    # remove log subscribers
    patterns = %w(sql.active_record
                  start_processing.action_controller
                  process_action.action_controller
                  render_template.action_view
                  render_partial.action_view
                  render_collection.action_view)

    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      subscriber.patterns.each do |pattern|
        ActiveSupport::Notifications.unsubscribe pattern if patterns.include?(pattern)
      end
    end
  end

  def attach_superlogger_log_subscribers
    require 'superlogger/action_controller_log_subscriber'
    require 'superlogger/action_view_log_subscriber'
    require 'superlogger/active_record_log_subscriber'
  end

  def session_id=(session_id)
    RequestStore.store[:superlogger_session_id] = session_id
  end

  def session_id
    RequestStore.store[:superlogger_session_id] || "NS-#{Thread.current.object_id}"
  end

  def request_id=(request_id)
    RequestStore.store[:superlogger_request_id] = request_id
  end

  def request_id
    RequestStore.store[:superlogger_request_id] || "NR-#{Thread.current.object_id}"
  end
end

require 'superlogger/railtie' if defined?(Rails)

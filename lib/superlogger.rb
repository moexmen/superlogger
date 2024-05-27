require 'superlogger/version'
require 'superlogger/logger'

module Superlogger
  @@enabled = false
  @@log_extra_fields = nil

  module_function

  def setup(app)
    return unless (Rails.env.production? || enabled)
    
    insert_superlogger_middleware(app)
    detach_existing_log_subscribers
    attach_superlogger_log_subscribers
  end

  def insert_superlogger_middleware(app)
    require 'superlogger/superlogger_middleware'

    # important to insert after session middleware so we can get the session id
    app.middleware.use Superlogger::SuperloggerMiddleware, {
      log_extra_fields: @@log_extra_fields
    }.compact
  end

  def detach_existing_log_subscribers
    # force log subscribers to attach first so we can remove them all
    require 'action_controller/log_subscriber'
    require 'active_record/log_subscriber'
    require 'action_view/log_subscriber'

    # remove log subscribers
    remove_patterns = %w(sql.active_record
                  start_processing.action_controller
                  process_action.action_controller
                  render_template.action_view
                  render_partial.action_view
                  render_collection.action_view)

    ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
      patterns = subscriber.patterns
      patterns = patterns.is_a?(Hash) ? patterns.keys : patterns

      patterns.each do |pattern|
        ActiveSupport::Notifications.unsubscribe pattern if remove_patterns.include?(pattern)
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
    RequestStore.store[:superlogger_session_id]
  end

  def request_id=(request_id)
    RequestStore.store[:superlogger_request_id] = request_id
  end

  def request_id
    RequestStore.store[:superlogger_request_id]
  end

  def enabled=(enabled)
    @@enabled=enabled
  end

  def enabled
    @@enabled
  end

  def log_extra_fields=(log_extra_fields)
    @@log_extra_fields=log_extra_fields
  end

  def log_extra_fields
    @@log_extra_fields
  end
end

require 'superlogger/railtie' if defined?(Rails)

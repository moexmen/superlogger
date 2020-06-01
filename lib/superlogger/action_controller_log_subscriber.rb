module Superlogger
  class ActionControllerLogSubscriber < ActiveSupport::LogSubscriber
    INTERNAL_PARAMS = %w(controller action format _method only_path)

    # start of controller action
    def start_processing(event)
      payload = event.payload
      logger.debug {{ controller: payload[:controller], action: payload[:action], params: payload[:params].except(*INTERNAL_PARAMS) }}
    end

    # end of controller action
    def process_action(event)
      payload = event.payload
      view_duration  = payload[:view_runtime].to_f.round(2) if payload.key?(:view_runtime)
      db_duration    = payload[:db_runtime].to_f.round(2) if payload.key?(:db_runtime)

      if payload[:exception]
        logger.fatal view_duration: view_duration, db_duration: db_duration, exception: payload[:exception]
      else
        logger.info view_duration: view_duration, db_duration: db_duration
      end
    end
  end
end

Superlogger::ActionControllerLogSubscriber.attach_to :action_controller

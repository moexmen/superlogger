module Superlogger
  class ActionControllerLogSubscriber < ActiveSupport::LogSubscriber
    INTERNAL_PARAMS = %w(controller action format _method only_path)

    # start of controller action
    def start_processing(event)
      payload = event.payload

      logger.debug controller: payload[:controller], action: payload[:action], params: payload[:params].except(*INTERNAL_PARAMS)
    end

    # end of controller action
    def process_action(event)
      payload = event.payload

      if payload[:exception]
        status = ActionDispatch::ExceptionWrapper.status_code_for_exception(payload[:exception][0])

        logger.fatal status: status, exception: payload[:exception]
      else
        # Assume status 401 if action finishes without status code and no exception
        # https://github.com/pcg79/devise/commit/1e2dab3c0ce49efe2b5940c15f47388c69d6731b
        payload[:status] ||= 401

        total_duration = event.duration.to_f.round(2)
        view_duration  = payload[:view_runtime].to_f.round(2) if payload.key?(:view_runtime)
        db_duration    = payload[:db_runtime].to_f.round(2) if payload.key?(:db_runtime)

        logger.info status: payload[:status], total_duration: total_duration, view_duration: view_duration, db_duration: db_duration
      end
    end
  end
end

Superlogger::ActionControllerLogSubscriber.attach_to :action_controller

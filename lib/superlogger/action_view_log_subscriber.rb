module Superlogger
  class ActionViewLogSubscriber < ActiveSupport::LogSubscriber
    def render_template(event)
      payload = event.payload

      logger.debug {{ view: payload[:identifier].split('/').last, duration: event.duration.round(2) }}
    end
    alias :render_partial :render_template
    alias :render_collection :render_template
  end
end

Superlogger::ActionViewLogSubscriber.attach_to :action_view

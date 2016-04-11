class ActionDispatch::DebugExceptions
  alias_method :old_log_error, :log_error
  def log_error(request, wrapper)
    if wrapper.exception.is_a?  ActionController::RoutingError
      # Change routing errors to warn instead
      Superlogger::Logger.warn routing_error: request['PATH_INFO'].inspect
    else
      old_log_error request, wrapper
    end
  end
end

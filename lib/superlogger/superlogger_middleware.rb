module Superlogger
  class SuperloggerMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      
      if request.path.start_with?('/assets/') == false
        process_request(request) { @app.call(env) }
      else
        @app.call(env)
      end
    end

    def process_request(request)
      setup_request_id_for_logging(request)
      setup_session_id_for_logging(request)

      # Start of request
      Rails.logger.info method: request.method, path: request.fullpath

      t1 = Time.now
      status, _headers, _response = yield
    ensure
      t2 = Time.now

      # End of request
      duration = ((t2 - t1) * 1000).to_f.round(2)

      # After the request has been processed, the session ID can change from what it was before the request
      # was processed. As such, we need to setup the session ID again.
      setup_session_id_for_logging(request)

      Rails.logger.info method: request.method, path: request.fullpath, response_time: duration, status: status

      [status, _headers, _response]
    end

    def setup_request_id_for_logging(request)
      Superlogger.request_id = request.uuid.try(:gsub, '-', '')
    end

    def setup_session_id_for_logging(request)
      return unless request.env['rack.session']&.id

      Superlogger.session_id = request.env['rack.session'].id.to_s
    end
  end
end

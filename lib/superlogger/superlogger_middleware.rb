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
      setup_logging(request)

      # Start of request
      Rails.logger.info method: request.method, path: request.fullpath

      t1 = Time.now
      status, _headers, _response = yield
    ensure
      t2 = Time.now

      # End of request
      duration = ((t2 - t1) * 1000).to_f.round(2)
      Rails.logger.info method: request.method, path: request.fullpath, response_time: duration, status: status

      [status, _headers, _response]
    end

    def setup_logging(request)
      if request.env['rack.session']
        # Session is lazy loaded. Force session to load if it is not already loaded.
        request.env['rack.session'].send(:load!) unless request.env['rack.session'].id

        # Store session id before any actual logging is done
        Superlogger.session_id = request.env['rack.session'].id.to_s
      end

      Superlogger.request_id = request.uuid.try(:gsub, '-', '')
    end
  end
end

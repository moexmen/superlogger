module Superlogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      # only process the actual request, less the assets
      if request.path.start_with?('/assets/') == false
        process_request(request)
      end

      @app.call(env)
    end

    def process_request(request)
      if request.env['rack.session']
        # Session is lazy loaded. Force session to load if it is not already loaded.
        request.env['rack.session'].send(:load!) unless request.env['rack.session'].id

        # Store session id before any actual logging is done
        Superlogger::Logger.session_id = request.env['rack.session'].id
      end

      # Start of request logging
      Logger.info method: request.method, path: request.fullpath, ip: request.ip
    end
  end
end

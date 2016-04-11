class Rails::Rack::Logger
  # Overwrite the default call_app method to mute the following line:
  # Started GET “/session/new” for 127.0.0.1 at 2012-09-26 14:51:42 -0700
  def call_app(_request, env)
    @app.call(env)
  ensure
    ActiveSupport::LogSubscriber.flush_all!
  end
end



module Superlogger
  class Railtie < Rails::Railtie
    config.superlogger = ActiveSupport::OrderedOptions.new
    config.superlogger.sql_enabled = false
    config.superlogger.squished = false

    initializer :superlogger do |app|
      Superlogger.setup(app)
    end
  end
end

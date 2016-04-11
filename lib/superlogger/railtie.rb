module Superlogger
  class Railtie < Rails::Railtie
    initializer :superlogger do |app|
      Superlogger.setup(app)
    end
  end
end

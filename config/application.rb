require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module StargazingBeauty
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "Kyiv"
    config.i18n.available_locales = [:uk, :en]
    config.i18n.default_locale = :uk
    config.generators.system_tests = nil
    config.active_job.queue_adapter = :inline
  end
end

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SfDahliaWeb
  # setting up config for application
  class Application < Rails::Application
    config.assets.paths << Rails.root.join('lib', 'assets', 'bower_components')

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # http://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    config.time_zone = 'Pacific Time (US & Canada)'

    # set up ActiveJob to use Sidekiq
    # if ENV['SIDEKIQ'] is not specified, will use default inline processor
    config.active_job.queue_adapter = :sidekiq if ENV['SIDEKIQ']

    ENV['GEOCODING_SERVICE_URL'] ||= 'https://sfgis-svc.sfgov.org/arcgis/rest/services/dt/NRHP_Composite/GeocodeServer/findAddressCandidates'
    ENV['NEIGHBORHOOD_BOUNDARY_SERVICE_URL'] ||= 'https://sfgis-svc.sfgov.org/arcgis/rest/services/dt/NRHP_pref/MapServer/0/query'
  end
end

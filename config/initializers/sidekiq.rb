# frozen_string_literal: true

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('WORKER_REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('WORKER_REDIS_URL', 'redis://localhost:6379/1') }

  config.on(:startup) do
    schedule_file = ENV.fetch('SCHEDULE_FILE')

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end
end

require 'sidekiq/throttled'
Sidekiq::Throttled.setup!

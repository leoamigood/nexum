# frozen_string_literal: true

require 'sidekiq-unique-jobs'

SidekiqUniqueJobs.configure do |config|
  config.enabled = !Rails.env.test?
  config.logger_enabled = !Rails.env.test?
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('WORKER_REDIS_URL', 'redis://localhost:6379/1') }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('WORKER_REDIS_URL', 'redis://localhost:6379/1') }

  config.on(:startup) do
    schedule_file = ENV.fetch('SCHEDULE_FILE')

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

require 'sidekiq/throttled'
Sidekiq::Throttled.setup!

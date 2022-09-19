# frozen_string_literal: true

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/1' }

  require 'octokit_resource'
  require 'tracer'
  require 'job_benchmarker'
  require 'resource_job_tracer'
  require 'user_resource_job_tracer'
  require 'repo_resource_job_tracer'
  require 'job_watcher'
  require 'user_surfer_job'
  require 'repo_surfer_job'
  require 'stats_surfer_job'
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

require 'sidekiq/throttled'
Sidekiq::Throttled.setup!

# frozen_string_literal: true

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/1' }
end

require 'sidekiq/throttled'
Sidekiq::Throttled.setup!

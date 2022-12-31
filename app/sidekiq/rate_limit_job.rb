# frozen_string_literal: true

class RateLimitJob
  include Sidekiq::Job
  include OctokitResource
  queue_as ENV.fetch('RATE_QUEUE', :critical)

  sidekiq_options retry: false

  def perform(*_args)
    RateLimiter.limits = client.rate_limit
    RateLimiter.queues = Sidekiq::Queue.all.map { |queue| { queue.name => queue.size } }.reduce({}, :merge)

    Rails.logger.info "Rate limits: #{RateLimiter.limits} for queues: #{RateLimiter.queues}"

    Turbo::StreamsChannel.broadcast_update_to('charts', target: sidekiq_options_hash['queue'], partial: 'charts/rate', locals: { limits: RateLimiter.limits })
  end
end

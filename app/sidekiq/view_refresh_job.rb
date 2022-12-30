# frozen_string_literal: true

class ViewRefreshJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job

  sidekiq_options queue: :periodical, retry: false

  sidekiq_throttle(concurrency: { limit: 1 })

  def perform(args)
    Scenic.database.refresh_materialized_view(args['table'], concurrently: args['concurrently'], cascade: false)
  end
end

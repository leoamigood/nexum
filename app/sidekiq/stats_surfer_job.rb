# frozen_string_literal: true

class StatsSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend RepoResourceJobTracer
  prepend JobWatcher
  queue_as :stats_surfer

  sidekiq_options queue: :stats_surfer, timeout: 1.hour

  sidekiq_throttle(threshold: { limit: 400, period: 1.hour })

  def perform(full_name)
    repository = Repository.find_by!(full_name:)

    stats = client.participation_stats(repository.full_name)

    repository.participation = stats.owner.sum
    repository.save!
  rescue Octokit::UnavailableForLegalReasons => e
    trace(:failed, full_name, message: e.message, value: e.class.name)
  end

  def ignore_recency?
    true
  end
end

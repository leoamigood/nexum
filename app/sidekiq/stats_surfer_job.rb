# frozen_string_literal: true

class StatsSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend RepoResourceJobTracer
  prepend JobWatcher

  sidekiq_options queue: :high, retry: 3

  sidekiq_throttle(concurrency: { limit: ->(_) { RateLimiter.limited?(get_sidekiq_options['queue']) ? 0 : ENV.fetch('SIDEKIQ_CONCURRENCY', 5) } })

  def perform(repo_full_name)
    repository = Repository.find_by!(full_name: repo_full_name)

    stats = client.participation_stats(repository.full_name)

    repository.participation = stats.owner.sum
    repository.save!
  rescue Octokit::UnavailableForLegalReasons => e
    trace(:failed, repo_full_name, message: e.message, value: resource)
  end

  def ignore_recency?
    true
  end
end

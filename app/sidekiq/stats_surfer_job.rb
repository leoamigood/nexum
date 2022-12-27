# frozen_string_literal: true

class StatsSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend ResourceJobTracer
  prepend JobWatcher

  sidekiq_options queue: :high, retry: 3, timeout: 5.minutes,
                  lock: :until_executed, on_conflict: { client: :log, server: :reject }

  sidekiq_throttle(concurrency: { limit: ->(_) { RateLimiter.limited?(get_sidekiq_options['queue']) ? 0 : ENV.fetch('SIDEKIQ_CONCURRENCY', 5) } })

  def perform(repo_full_name)
    repository = Repository.find_by!(full_name: repo_full_name)

    stats = client.participation_stats(repository.full_name)

    repository.participation = stats.owner.sum
    repository.save!
  rescue Octokit::UnavailableForLegalReasons, Octokit::RepositoryUnavailable => e
    trace(:warning, repo_full_name, message: e.message, value: e.class.name)
  end
end

# frozen_string_literal: true

class RepoSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend RepoResourceJobTracer
  prepend JobWatcher

  sidekiq_options queue: :medium

  sidekiq_throttle(
    concurrency: { limit: 1 },
    threshold:   { limit: 500, period: 1.hour }
  )

  def perform(username)
    developer = Developer.find_by!(username:)

    persist(developer, client.repos(developer.username, per_page:))
    paginate(client.last_response) { |repos| persist(developer, repos) }
  end

  private

  def persist(developer, repos)
    discovered = filter_out_existing(repos)
    return if discovered.blank?

    repositories = discovered.map do |repo|
      Repository.build(repo)
                .assign(owner_name: repo.owner.login, developer_id: developer.id)
                .assign(visited_at: Time.current)
    end
    Repository.insert_all(repositories.map(&:attributes))

    repositories.each do |repo|
      ContentSurferJob.perform_async(repo.full_name)
      StatsSurferJob.perform_async(repo.full_name)
    end
  end

  def filter_out_existing(repos)
    existing = Repository.where(id: repos.map(&:id))
    repos.reject { |repo| existing.include?(repo) }
  end
end

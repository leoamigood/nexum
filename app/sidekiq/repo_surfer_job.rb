# frozen_string_literal: true

class RepoSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend RepoResourceJobTracer
  prepend JobWatcher
  queue_as :repo_surfer

  sidekiq_options queue: :repo_surfer, timeout: 10.hours

  sidekiq_throttle(threshold: { limit: 500, period: 1.hour })

  def perform(username)
    user = client.user(username)
    developer = Developer.find_by!(username: user.login)

    repos = client.repos(developer.username, per_page:)
    discover(developer, repos)

    paginate(client.last_response) { |repos| discover(developer, repos) }
  end

  private

  def discover(developer, repos)
    persisted = Repository.where(id: repos.map(&:id))
    discovered = repos.reject { |repo| persisted.include?(repo) }
    return if discovered.blank?

    Repository.insert_all(
      discovered.map do |repo|
        Repository.build(repo)
                  .with(owner_name: repo.owner.login, developer_id: developer.id)
                  .with(visited_at: Time.current)
                  .attributes
      end
    )
  end
end

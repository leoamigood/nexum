# frozen_string_literal: true

class RepoSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend RepoResourceJobTracer
  queue_as :repo_surfer

  sidekiq_options queue: :repo_surfer

  sidekiq_throttle(
    concurrency: { limit: 1, key_suffix: ->(key) { key } },
    threshold:   { limit: 1000, period: 1.hour },
    observer:    ->(strategy, *args) { Rails.logger.info "THROTTLED: #{strategy}, #{args}" }
  )

  def perform(username)
    user = client.user(username)
    developer = Developer.find_by!(username: user.login)

    repos = client.repos(developer.username, per_page:)
    developer.repositories << repos.map { |repo| Repository.persist(repo) }

    paginate(client.last_response) do |repos|
      developer.repositories << repos.map { |repo| Repository.persist(repo) }
    end
  end
end

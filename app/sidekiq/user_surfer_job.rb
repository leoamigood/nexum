# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobBenchmarker
  prepend UserResourceJobTracer
  prepend JobWatcher
  queue_as :medium

  sidekiq_options queue: :medium

  sidekiq_throttle(
    concurrency: { limit: 1 },
    threshold:   { limit: 500, period: 1.hour }
  )

  def perform(username)
    user = client.user(username)
    developer = Developer.persist!(user)

    surface_repos(developer)
    surface_follows(developer)

    developer.visited!
  end

  private

  def surface_repos(developer)
    RepoSurferJob.perform_async(developer.username)
  end

  def surface_follows(developer)
    followers = client.followers(developer.username, per_page:)
    usernames = surface_users(followers)
    developer.followers << Developer.where(username: usernames)

    following = client.following(developer.username, per_page:)
    usernames = surface_users(following)
    developer.following << Developer.where(username: usernames)
  end

  def surface_users(users)
    undiscovered = users.map(&:login) - Developer.where(username: users.map(&:login)).pluck(:username)
    Developer.insert_all(undiscovered.map { |username| { username: } }) if undiscovered.present?

    undiscovered.each { |username| UserSurferJob.perform_async(username) }
    undiscovered
  end
end

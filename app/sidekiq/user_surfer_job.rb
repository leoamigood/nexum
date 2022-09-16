# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Job
  include Sidekiq::Throttled::Job
  include OctokitResource
  prepend JobWatcher
  prepend UserResourceJobTracer
  queue_as :user_surfer

  sidekiq_options queue: :user_surfer, timeout: 10.minutes

  sidekiq_throttle(
    concurrency: { limit: 1, key_suffix: ->(key) { key } },
    threshold:   { limit: 1000, period: 1.hour },
    observer:    ->(strategy, *args) { Rails.logger.info "THROTTLED: #{strategy}, #{args}" }
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
    surface_followers(developer) do |accounts|
      surface_accounts(accounts)
      developer.followers |= Developer.where(username: accounts.map(&:login))
    end

    surface_following(developer) do |accounts|
      surface_accounts(accounts)
      developer.following |= Developer.where(username: accounts.map(&:login))
    end
  end

  def surface_followers(developer)
    yield client.followers(developer.username, per_page:)
  end

  def surface_following(developer)
    yield client.following(developer.username, per_page:)
  end

  def surface_accounts(accounts)
    accounts
      .reject { |account| Developer.find_by(username: account.login)&.username }
      .map { |account| Developer.create!(username: account.login) }
      .each { |user| UserSurferJob.perform_async(user.username) }
  end
end

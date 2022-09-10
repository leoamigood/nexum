# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include OctokitResource
  queue_as :surfer

  sidekiq_options queue: :surfer

  sidekiq_throttle(
    concurrency: { limit: 5 },
    threshold:   { limit: 2_000, period: 1.hour }
  )

  def perform(username, leader_name = nil, follower_name = nil)
    SurfTrace.attempt(username)
    if visited?(username)
      SurfTrace.skipped(username)
    else
      SurfTrace.progress(username)
      surface(username, leader_name, follower_name)
      SurfTrace.succeed(username)
    end
  rescue Exception => e
    SurfTrace.failed(username:, message: e.message)
  end

  def surface(username, leader_name, follower_name)
    user = client.user(username)
    developer = Elite.persist(user)

    leader = Elite.find_by(username: leader_name)
    follower = Elite.find_by(username: follower_name)

    leader.followers << developer if leader.present?
    follower.following << developer if follower.present?

    surface_repos(developer)
    surface_followers(developer)
    surface_following(developer)
  end

  def surface_followers(developer)
    followers = client.followers(developer.username)
    followers.each do |user|
      UserSurferJob.perform_async(user.login, developer.username, nil)
    end
  end

  def surface_following(developer)
    following = client.following(developer.username)
    following.each do |user|
      UserSurferJob.perform_async(user.login, nil, developer.username)
    end
  end

  def surface_repos(developer)
    repos = client.repos(developer.username)
    developer.repositories << repos.map { |repo| Repository.persist(repo) }
  end
end

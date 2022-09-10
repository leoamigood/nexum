# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Worker
  include OctokitResource
  extend Limiter::Mixin
  queue_as :surfer

  limit_method(:surface, rate: 2500, interval: 3600, balanced: Rails.configuration.x.throttling.balance)

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
end

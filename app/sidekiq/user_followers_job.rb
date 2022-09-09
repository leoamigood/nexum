# frozen_string_literal: true

class UserFollowersJob
  include Sidekiq::Worker
  queue_as :surfer

  def perform(username)
    client = OctokitClient.client

    begin
      user = client.user(username)
      Rails.logger.info("Using #{self.class} to process #{username}...")
      Rails.logger.info("Found #{user.followers} followers...")

      if user.followers.positive?
        followers = client.followers(user)
        followers.each do |follower|
          UserSurferJob.perform_async(follower.login)
        end
      end

    rescue Octokit::NotFound => e
      Rails.logger.info(e.message)
    end
  end
end

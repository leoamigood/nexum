# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Worker
  queue_as :surfer

  def perform(username)
    client = OctokitClient.client

    begin
      user = client.user(username)
      Rails.logger.info("Processing user #{username}...")

      UserFollowersJob.perform_async(user.login) if user.followers.positive?

    rescue Octokit::NotFound => e
      Rails.logger.info(e.message)
    end
  end
end

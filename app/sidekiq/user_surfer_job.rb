# frozen_string_literal: true

class UserSurferJob
  include Sidekiq::Worker
  prepend Tracer::JobTracer
  queue_as :surfer

  def perform(username)
    client = OctokitClient.client

    user = client.user(username)
    SurfTrace.progress(user)

    UserResource.persist(user)

    # UserFollowersJob.perform_async(user.login) if user.followers.positive?
    user
  end
end

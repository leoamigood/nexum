# frozen_string_literal: true

class PriorityUserSurferJob < UserSurferJob
  sidekiq_options queue: :priority, timeout: 30.minutes

  def surface_repos(developer)
    PriorityRepoSurferJob.perform_async(developer.username, { 'token' => token })
  end

  def revisit?(_)
    true
  end
end

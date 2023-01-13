# frozen_string_literal: true

class PriorityRepoSurferJob < RepoSurferJob
  sidekiq_options queue: :priority, timeout: 30.minutes
end

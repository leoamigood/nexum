# frozen_string_literal: true

class Repository < ApplicationRecord
  include Traceable

  belongs_to :developer

  class << self
    def persist(repo)
      find_or_create_by(full_name: repo.full_name) do |resource|
        resource.name             = repo.name
        resource.full_name        = repo.full_name
        resource.owner_name       = repo.owner.login
        resource.private          = repo.private
        resource.html_url         = repo.html_url
        resource.homepage         = repo.homepage
        resource.topics           = repo.topics
        resource.archived         = repo.archived
        resource.disabled         = repo.disabled
        resource.description      = repo.description
        resource.fork             = repo.fork
        resource.language         = repo.language
        resource.forks_count      = repo.forks_count
        resource.stargazers_count = repo.stargazers_count
        resource.watchers_count   = repo.watchers_count
        resource.size             = repo.size
        resource.default_branch   = repo.default_branch
        resource.visibility       = repo.visibility
        resource.created_time     = repo.created_at
        resource.updated_time     = repo.updated_at
        resource.node_id          = repo.node_id

        resource.visited_at       = Time.current
      end
    end

    def recently_visited?(full_name)
      recent.where(full_name:).present?
    end
  end
end

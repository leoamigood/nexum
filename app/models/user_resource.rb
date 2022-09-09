# frozen_string_literal: true

class UserResource < ApplicationRecord
  class << self
    def persist(resource)
      UserResource.create!(
        node_id:          resource.node_id,
        login:            resource.login,
        avatar_url:       resource.avatar_url,
        followers:        resource.followers,
        name:             resource.name,
        company:          resource.company,
        location:         resource.location,
        email:            resource.email,
        twitter_username: resource.twitter_username
      )
    end
  end
end

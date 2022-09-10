# frozen_string_literal: true

class Elite < ApplicationRecord
  has_many :follows, dependent: :destroy

  has_many :follower_relationships, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :following, through: :following_relationships, source: :elite

  class << self
    def persist(user)
      Elite.find_or_create_by(username: user.login) do |resource|
        resource.name             = user.name
        resource.email            = user.email
        resource.avatar_url       = user.avatar_url
        resource.followers_count  = user.followers
        resource.following_count  = user.following
        resource.company          = user.company
        resource.location         = user.location
        resource.node_id          = user.node_id
        resource.twitter_username = user.twitter_username
      end
    end
  end
end

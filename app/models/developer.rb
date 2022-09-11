# frozen_string_literal: true

class Developer < ApplicationRecord
  include Traceable

  has_many :follows, dependent: :destroy
  has_many :repositories, dependent: :destroy

  has_many :follower_relationships, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :following, through: :following_relationships, source: :developer

  class << self
    def persist!(user)
      developer = find_or_create_by!(username: user.login)

      developer.name             = user.name
      developer.email            = user.email
      developer.avatar_url       = user.avatar_url
      developer.followers_count  = user.followers
      developer.following_count  = user.following
      developer.company          = user.company
      developer.location         = user.location
      developer.node_id          = user.node_id
      developer.twitter_username = user.twitter_username
      developer.save!

      developer
    end

    def recently_visited?(username)
      recent.where(username:).present?
    end
  end

  def visited!
    self.visited_at = Time.current
    save!
  end
end

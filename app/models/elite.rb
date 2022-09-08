# frozen_string_literal: true

class Elite < ApplicationRecord
  has_many :follows, dependent: :destroy

  has_many :follower_relationships, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :following, through: :following_relationships, source: :elite
end

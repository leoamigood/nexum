# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'Elite'
  belongs_to :elite, class_name: 'Elite'

  validates :follower_id, uniqueness: { scope: :elite_id }
end

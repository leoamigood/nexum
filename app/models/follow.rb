# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :follower, class_name: "Developer"
  belongs_to :developer

  validates :follower_id, uniqueness: {scope: :developer_id}
end

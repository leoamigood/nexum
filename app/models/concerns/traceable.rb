# frozen_string_literal: true

module Traceable
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { where('visited_at > ?', 7.days.ago) }
  end
end

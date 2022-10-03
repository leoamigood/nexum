# frozen_string_literal: true

module Traceable
  extend ActiveSupport::Concern

  RECENCY_PERIOD = 1.year

  included do
    scope :recent, -> { where('visited_at > ?', RECENCY_PERIOD.ago) }
  end
end

# frozen_string_literal: true

class RateLimiter
  RATE_BUFFER = 500

  @queues = {}

  class << self
    attr_accessor :limits, :queues

    def limited?(queue_name)
      return true if limit_reached?

      case queue_name.to_s
      when 'medium'
        @queues['high'].to_i.positive?
      when 'low'
        @queues['medium'].to_i.positive?
      else
        false
      end
    end

    def limit_reached?
      [@limits&.remaining.to_i - RATE_BUFFER, 0].max.zero?
    end
  end
end

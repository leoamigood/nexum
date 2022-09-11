# frozen_string_literal: true

class Trace < ApplicationRecord
  class << self
    def attempt(domain, value)
      create!(key: domain.trace_by, value:, domain:, state: Enum::TraceState::ATTEMPTED)
    end

    def progress(domain, value)
      create!(key: domain.trace_by, value:, domain:, state: Enum::TraceState::IN_PROGRESS)
    end

    def skipped(domain, value)
      create!(key: domain.trace_by, value:, domain:, state: Enum::TraceState::SKIPPED)
    end

    def succeed(domain, value)
      create!(key: domain.trace_by, value:, domain:, state: Enum::TraceState::SUCCEEDED)
    end

    def failed(domain, value, message)
      create!(key: domain.trace_by, value:, domain:, state: Enum::TraceState::FAILED, message:)
    end
  end
end

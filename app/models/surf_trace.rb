# frozen_string_literal: true

class SurfTrace < ApplicationRecord
  class << self
    def attempt(username)
      SurfTrace.create!(username:, state: Enum::ResourceState::ATTEMPTED)
    end

    def progress(username)
      SurfTrace.create!(username:, state: Enum::ResourceState::IN_PROGRESS)
    end

    def skipped(username)
      SurfTrace.create!(username:, state: Enum::ResourceState::SKIPPED)
    end

    def succeed(username)
      SurfTrace.create!(username:, state: Enum::ResourceState::SUCCEEDED)
    end

    def failed(username:, message:)
      SurfTrace.create!(username:, state: Enum::ResourceState::FAILED, message:)
    end
  end
end

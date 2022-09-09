# frozen_string_literal: true

class SurfTrace < ApplicationRecord
  class << self
    def attempt(username)
      SurfTrace.create!(username:, state: Enum::ResourceState::ATTEMPTED)
    end

    def progress(resource)
      SurfTrace.create!(node_id: resource.node_id, state: Enum::ResourceState::IN_PROGRESS)
    end

    def succeed(resource)
      SurfTrace.create!(username: resource.login, node_id: resource.node_id, state: Enum::ResourceState::SUCCEEDED)
    end

    def failed(username:, message:)
      SurfTrace.create!(username:, state: Enum::ResourceState::FAILED, message:)
    end
  end
end

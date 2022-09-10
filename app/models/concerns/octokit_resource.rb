# frozen_string_literal: true

module OctokitResource
  extend ActiveSupport::Concern

  included do
    def client
      OctokitClient.client
    end

    def visited?(username)
      Elite.where(username:).present?
    end

    delegate :user, to: :client
  end
end

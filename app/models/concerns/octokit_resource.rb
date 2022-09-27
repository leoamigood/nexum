# frozen_string_literal: true

module OctokitResource
  extend ActiveSupport::Concern

  DEFAULT_PAGE_SIZE = 100

  PROVIDER_GITHUB = "github"
  GITHUB_CREDENTIALS = [
    "type" => "git_source",
    "host" => "github.com",
    "password" => Rails.application.credentials.github_access_token!
  ].freeze

  included do
    def client
      @client ||= OctokitClient.client
    end

    def per_page
      DEFAULT_PAGE_SIZE
    end

    def paginate(last_response)
      while last_response.rels[:next]
        last_response = last_response.rels[:next].get
        yield last_response.data
      end
    end
  end
end

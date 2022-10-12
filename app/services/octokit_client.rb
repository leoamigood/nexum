# frozen_string_literal: true

class OctokitClient
  PROVIDER_GITHUB = 'github'

  GITHUB_CREDENTIALS = [
    'type'     => 'git_source',
    'host'     => 'github.com',
    'password' => ENV.fetch('GITHUB_ACCESS_TOKEN', Rails.application.credentials.github_access_token!)
  ].freeze

  class << self
    def client
      Octokit::Client.new(access_token: github_access_token!)
    end

    def github_access_token!
      GITHUB_CREDENTIALS.detect { |e| e['password'].present? }['password']
    end
  end
end

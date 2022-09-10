# frozen_string_literal: true

class OctokitClient
  class << self
    def client
      Octokit::Client.new(access_token: Rails.application.credentials.github_access_token!)
    end
  end
end

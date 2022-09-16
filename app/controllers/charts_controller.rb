class ChartsController < ApplicationController
  COMMON_LANGUAGES = %w[JavaScript Ruby C++ C Java Python Java PHP Go].freeze

  def index
    @repos_by_language = Repository.where(language: COMMON_LANGUAGES, fork: false)
    @users_by_language = Repository.from(@repos_by_language.select(:language).group(:owner_name, :language))
    render
  end
end

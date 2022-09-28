# frozen_string_literal: true

class ChartsController < ApplicationController
  COMMON_LANGUAGES = %w[JavaScript Ruby C++ C Java Python Java PHP Go].freeze

  def index
    @repos_by_language = Repository.where(language: COMMON_LANGUAGES, fork: false)
    @users_by_language = Repository.from(@repos_by_language.select(:language).group(:owner_name, :language))

    sql = %{
      SELECT language, count(language)
      FROM repositories
      GROUP BY language
      ORDER BY count(language) DESC
      LIMIT 25
    }
    @technologies = ActiveRecord::Base.connection.execute(sql).values

    sql = %{
      SELECT to_char(visited_at, 'YYYY-MM-DD'), SUM(count(*)) OVER (ORDER BY to_char(visited_at, 'YYYY-MM-DD'))
      FROM developers
      WHERE visited_at IS NOT NULL
      GROUP BY to_char(visited_at, 'YYYY-MM-DD')
      ORDER BY to_char(visited_at, 'YYYY-MM-DD')
    }
    @developers = ActiveRecord::Base.connection.execute(sql).values

    sql = %{
      SELECT to_char(visited_at, 'YYYY-MM-DD'), SUM(count(*)) OVER (ORDER BY to_char(visited_at, 'YYYY-MM-DD'))
      FROM repositories
      WHERE visited_at IS NOT NULL
      GROUP BY to_char(visited_at, 'YYYY-MM-DD')
      ORDER BY to_char(visited_at, 'YYYY-MM-DD')
    }
    @repositories = ActiveRecord::Base.connection.execute(sql).values

    sql = %{
      SELECT unnest(topics) topic, count(*)
      FROM repositories
      GROUP BY topic
      ORDER BY count(*) DESC
      LIMIT 50
    }
    @keywords = ActiveRecord::Base.connection.execute(sql).values
    render
  end
end

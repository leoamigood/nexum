# frozen_string_literal: true

class ChartsController < ApplicationController
  COMMON_LANGUAGES = %w[JavaScript Ruby C++ C Java Python Java PHP Go].freeze

  def index
    sql = %{
      SELECT * FROM (
        SELECT visited_date, SUM(visited_count) OVER (ORDER BY visited_date)
        FROM developers_stats
        ORDER BY visited_date DESC
        LIMIT 14
      ) developers
      ORDER BY visited_date ASC
    }
    @developers = ActiveRecord::Base.connection.execute(sql).values

    sql = %(
      SELECT visited_date, visited_count
      FROM developers_stats
      ORDER BY visited_date DESC
      LIMIT 14
    )
    @daily_devs = ActiveRecord::Base.connection.execute(sql).values

    sql = %{
      SELECT * FROM (
        SELECT visited_date, SUM(visited_count) OVER (ORDER BY visited_date)
        FROM repositories_stats
        ORDER BY visited_date DESC
        LIMIT 14
      ) repositories
      ORDER BY visited_date ASC
    }
    @repositories = ActiveRecord::Base.connection.execute(sql).values

    sql = %(
      SELECT visited_date, visited_count
      FROM repositories_stats
      ORDER BY visited_date DESC
      LIMIT 14
    )
    @daily_repos = ActiveRecord::Base.connection.execute(sql).values
    render
  end

  def stats
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

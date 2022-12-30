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

    sql = %{
      SELECT to_char(created_at, 'YYYY-MM-DD') visited_at,
             percentile_cont(.5) within group (ORDER BY CAST(value AS float)) AS percentile_50,
             percentile_cont(.95) within group (ORDER BY CAST(value AS float)) AS percentile_95,
             percentile_cont(.99) within group (ORDER BY CAST(value AS float)) AS percentile_99
      FROM traces
      WHERE state = 'benchmark'
      GROUP BY to_char(created_at, 'YYYY-MM-DD')
      ORDER BY to_char(created_at, 'YYYY-MM-DD') ASC
    }
    values = ActiveRecord::Base.connection.execute(sql).values
    @performance = values.each_with_object(Hash.new { {} }) do |line, result|
      result['50%'] = result['50%'].merge(line[0] => line[1])
      result['95%'] = result['95%'].merge(line[0] => line[2])
      result['99%'] = result['99%'].merge(line[0] => line[3])
    end

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

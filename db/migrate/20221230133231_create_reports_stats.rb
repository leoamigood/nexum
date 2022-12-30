# frozen_string_literal: true

class CreateReportsStats < ActiveRecord::Migration[7.0]
  def change
    create_view :developers_stats, materialized: true
    add_index :developers_stats, :visited_date, unique: true

    create_view :repositories_stats, materialized: true
    add_index :repositories_stats, :visited_date, unique: true
  end
end

# frozen_string_literal: true

class AddRepoDevIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :repositories, :language
    add_index :repositories, :visited_at
    add_index :repositories, :developer_id

    add_index :developers, :visited_at
  end
end

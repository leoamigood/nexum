# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.bigint :developer_id, foreign_key: true
      t.string :name, index: true
      t.string :full_name
      t.string :owner_name, index: true
      t.integer :participation, null: true
      t.boolean :private
      t.string :html_url
      t.string :homepage
      t.string :topics, default: [], array: true
      t.boolean :archived
      t.boolean :disabled
      t.string :description
      t.boolean :fork
      t.string :language
      t.integer :forks_count
      t.integer :stargazers_count
      t.integer :watchers_count
      t.integer :size
      t.string :default_branch
      t.string :visibility
      t.string :node_id
      t.timestamp :visited_at, default: nil

      t.timestamps
      t.index :full_name, unique: true
    end
  end
end

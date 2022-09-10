# frozen_string_literal: true

class CreateElites < ActiveRecord::Migration[7.0]
  def up
    create_table :elites do |t|
      t.string  :name, index: true
      t.string  :username, index: true
      t.string  :email
      t.string  :avatar_url
      t.integer :followers_count
      t.integer :following_count
      t.string  :company, index: true
      t.string  :location, index: true
      t.string  :node_id, index: true
      t.string  :twitter_username

      t.timestamps
    end

    create_table :follows do |t|
      t.integer :elite_id, foreign_key: true, index: true
      t.integer :follower_id, foreign_key: true, index: true
      t.integer :weight

      t.timestamps
    end
    add_index :follows, %i[elite_id follower_id], unique: true
  end
end

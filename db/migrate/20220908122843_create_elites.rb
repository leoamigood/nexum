# frozen_string_literal: true

class CreateElites < ActiveRecord::Migration[7.0]
  def up
    create_table :elites do |t|
      t.string  :username, unique: true

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

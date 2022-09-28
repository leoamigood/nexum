# frozen_string_literal: true

class CreateLibraries < ActiveRecord::Migration[7.0]
  def change
    create_table :libraries, id: false do |t|
      t.bigint    :repository_id, foreign_key: true
      t.string    :name, null: false, index: true
      t.string    :version
      t.string    :manager, null: false, index: true
    end
  end
end

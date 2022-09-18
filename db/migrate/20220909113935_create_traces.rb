# frozen_string_literal: true

class CreateTraces < ActiveRecord::Migration[7.0]
  def change
    create_table :traces do |t|
      t.string  :username, index: true, null: false
      t.string  :state, index: true, null: false
      t.string  :message, null: true
      t.string  :resource, index: true, null: false
      t.string  :value, null: true

      t.timestamps
    end
  end
end

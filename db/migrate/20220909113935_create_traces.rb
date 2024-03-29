# frozen_string_literal: true

class CreateTraces < ActiveRecord::Migration[7.0]
  def change
    create_table :traces do |t|
      t.string  :name, index: true, null: false
      t.string  :state, index: true, null: false
      t.string  :message, null: true
      t.string  :tracer, index: true, null: false
      t.string  :value, null: true

      t.timestamps
    end
  end
end

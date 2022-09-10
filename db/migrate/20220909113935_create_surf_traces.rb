# frozen_string_literal: true

class CreateSurfTraces < ActiveRecord::Migration[7.0]
  def change
    create_table :surf_traces do |t|
      t.string  :username, index: true
      t.string  :state, null: false, index: true
      t.string  :message

      t.timestamps
    end
  end
end

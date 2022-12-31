# frozen_string_literal: true

class AddLibrariesIndexOnRepositoryId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_index :libraries, :repository_id, algorithm: :concurrently
  end
end

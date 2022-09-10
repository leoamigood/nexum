class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.bigint    :elite_id, foreign_key: true, index: true
      t.string    :name, index: true
      t.string    :full_name
      t.string    :owner_name, index: true
      t.boolean   :private
      t.string    :html_url
      t.string    :homepage
      t.string    :topics, default: [], array: true
      t.boolean   :archived
      t.boolean   :disabled
      t.string    :description
      t.boolean   :fork
      t.string    :language
      t.integer   :forks_count
      t.integer   :stargazers_count
      t.integer   :watchers_count
      t.integer   :size
      t.string    :default_branch
      t.string    :visibility
      t.datetime  :created_time
      t.datetime  :updated_time
      t.string    :node_id

      t.timestamps
    end
  end
end

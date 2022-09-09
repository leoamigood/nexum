class CreateUserResource < ActiveRecord::Migration[7.0]
  def change
    create_table :user_resources do |t|
      t.string  :node_id, index: true
      t.string  :login, index: true
      t.string  :avatar_url
      t.integer :followers
      t.string  :name, index: true
      t.string  :company, index: true
      t.string  :location, index: true
      t.string  :email
      t.boolean :twitter_username

      t.timestamps
    end
  end
end

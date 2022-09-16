# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_10_135909) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "developers", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "email"
    t.string "avatar_url"
    t.integer "followers_count"
    t.integer "following_count"
    t.string "company"
    t.string "location"
    t.string "node_id"
    t.string "twitter_username"
    t.datetime "visited_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company"], name: "index_developers_on_company"
    t.index ["location"], name: "index_developers_on_location"
    t.index ["name"], name: "index_developers_on_name"
    t.index ["node_id"], name: "index_developers_on_node_id"
    t.index ["username"], name: "index_developers_on_username"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "developer_id"
    t.integer "follower_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id", "follower_id"], name: "index_follows_on_developer_id_and_follower_id", unique: true
    t.index ["developer_id"], name: "index_follows_on_developer_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.bigint "developer_id"
    t.string "name"
    t.string "full_name"
    t.string "owner_name"
    t.boolean "private"
    t.string "html_url"
    t.string "homepage"
    t.string "topics", default: [], array: true
    t.boolean "archived"
    t.boolean "disabled"
    t.string "description"
    t.boolean "fork"
    t.string "language"
    t.integer "forks_count"
    t.integer "stargazers_count"
    t.integer "watchers_count"
    t.integer "size"
    t.string "default_branch"
    t.string "visibility"
    t.datetime "created_time"
    t.datetime "updated_time"
    t.string "node_id"
    t.datetime "visited_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id"], name: "index_repositories_on_developer_id"
    t.index ["name"], name: "index_repositories_on_name"
    t.index ["owner_name"], name: "index_repositories_on_owner_name"
  end

  create_table "traces", force: :cascade do |t|
    t.string "value", null: false
    t.string "state", null: false
    t.string "message"
    t.string "resource", null: false
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource"], name: "index_traces_on_resource"
    t.index ["state"], name: "index_traces_on_state"
    t.index ["value"], name: "index_traces_on_value"
  end

end
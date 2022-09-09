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

ActiveRecord::Schema[7.0].define(version: 2022_09_09_134321) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "elites", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.integer "elite_id"
    t.integer "follower_id"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["elite_id", "follower_id"], name: "index_follows_on_elite_id_and_follower_id", unique: true
    t.index ["elite_id"], name: "index_follows_on_elite_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "surf_traces", force: :cascade do |t|
    t.string "username"
    t.string "node_id"
    t.string "state", null: false
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_surf_traces_on_node_id"
    t.index ["username"], name: "index_surf_traces_on_username"
  end

  create_table "user_resources", force: :cascade do |t|
    t.string "node_id"
    t.string "login"
    t.string "avatar_url"
    t.integer "followers"
    t.string "name"
    t.string "company"
    t.string "location"
    t.string "email"
    t.boolean "twitter_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company"], name: "index_user_resources_on_company"
    t.index ["location"], name: "index_user_resources_on_location"
    t.index ["login"], name: "index_user_resources_on_login"
    t.index ["name"], name: "index_user_resources_on_name"
    t.index ["node_id"], name: "index_user_resources_on_node_id"
  end

end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_19_210859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer "season"
    t.string "home_team_name"
    t.string "away_team_name"
    t.integer "home_team_drives"
    t.integer "away_team_drives"
    t.integer "home_team_score"
    t.integer "away_team_score"
    t.integer "api_ref"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "week"
    t.index ["api_ref", "away_team_name", "home_team_name", "season", "week"], name: "game_unique_index", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.string "name"
    t.integer "season"
    t.bigint "team_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "value"
    t.index ["game_id", "name", "season", "team_id"], name: "index_stats_on_game_id_and_name_and_season_and_team_id", unique: true
    t.index ["game_id"], name: "index_stats_on_game_id"
    t.index ["team_id"], name: "index_stats_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "stats", "games"
  add_foreign_key "stats", "teams"
end

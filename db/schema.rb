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

ActiveRecord::Schema[7.2].define(version: 2026_09_24_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.text "description"
    t.integer "total_units"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "common_areas", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "capacity"
    t.decimal "hourly_rate"
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_common_areas_on_building_id"
  end

  create_table "maintenance_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "unit_id", null: false
    t.string "title"
    t.text "description"
    t.string "priority"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.index ["category"], name: "index_maintenance_requests_on_category"
    t.index ["unit_id"], name: "index_maintenance_requests_on_unit_id"
    t.index ["user_id"], name: "index_maintenance_requests_on_user_id"
  end

  create_table "notices", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "building_id", null: false
    t.string "priority"
    t.datetime "published_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_notices_on_building_id"
    t.index ["user_id"], name: "index_notices_on_user_id"
  end

  create_table "owners", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "units_owned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_owners_on_user_id"
  end

  create_table "ownerships", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.bigint "unit_id", null: false
    t.decimal "ownership_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_ownerships_on_owner_id"
    t.index ["unit_id"], name: "index_ownerships_on_unit_id"
  end

  create_table "packages", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.string "recipient_name", null: false
    t.string "sender"
    t.string "carrier"
    t.string "tracking_code"
    t.string "status", default: "received", null: false
    t.datetime "received_at"
    t.datetime "notified_at"
    t.datetime "picked_up_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_packages_on_status"
    t.index ["tracking_code"], name: "index_packages_on_tracking_code"
    t.index ["unit_id"], name: "index_packages_on_unit_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "unit_id", null: false
    t.decimal "amount"
    t.string "payment_type"
    t.date "due_date"
    t.datetime "paid_at"
    t.string "status"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_payments_on_unit_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "poll_options", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.string "text", null: false
    t.integer "votes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.bigint "building_id", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "open", null: false
    t.datetime "closes_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_polls_on_building_id"
    t.index ["status"], name: "index_polls_on_status"
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "common_area_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.decimal "total_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_area_id"], name: "index_reservations_on_common_area_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "residents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "unit_id", null: false
    t.date "move_in_date"
    t.date "move_out_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_residents_on_unit_id"
    t.index ["user_id"], name: "index_residents_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "unit_number"
    t.bigint "building_id", null: false
    t.string "unit_type"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.decimal "area"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_units_on_building_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "password_digest"
    t.string "role"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "violations", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.bigint "reported_by_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "violation_type", default: "other", null: false
    t.string "severity", default: "medium", null: false
    t.string "status", default: "open", null: false
    t.decimal "fine_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_by_id"], name: "index_violations_on_reported_by_id"
    t.index ["status"], name: "index_violations_on_status"
    t.index ["unit_id"], name: "index_violations_on_unit_id"
    t.index ["violation_type"], name: "index_violations_on_violation_type"
  end

  create_table "visitors", force: :cascade do |t|
    t.string "name"
    t.string "id_number"
    t.string "phone"
    t.date "visit_date"
    t.datetime "visit_time"
    t.bigint "resident_id", null: false
    t.string "purpose"
    t.boolean "approved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.datetime "checked_in_at"
    t.datetime "checked_out_at"
    t.index ["resident_id"], name: "index_visitors_on_resident_id"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.bigint "poll_option_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "user_id"], name: "index_votes_on_poll_id_and_user_id", unique: true
    t.index ["poll_id"], name: "index_votes_on_poll_id"
    t.index ["poll_option_id"], name: "index_votes_on_poll_option_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "common_areas", "buildings"
  add_foreign_key "maintenance_requests", "units"
  add_foreign_key "maintenance_requests", "users"
  add_foreign_key "notices", "buildings"
  add_foreign_key "notices", "users"
  add_foreign_key "owners", "users"
  add_foreign_key "ownerships", "owners"
  add_foreign_key "ownerships", "units"
  add_foreign_key "packages", "units"
  add_foreign_key "payments", "units"
  add_foreign_key "payments", "users"
  add_foreign_key "poll_options", "polls"
  add_foreign_key "polls", "buildings"
  add_foreign_key "polls", "users"
  add_foreign_key "reservations", "common_areas"
  add_foreign_key "reservations", "users"
  add_foreign_key "residents", "units"
  add_foreign_key "residents", "users"
  add_foreign_key "units", "buildings"
  add_foreign_key "violations", "units"
  add_foreign_key "violations", "users", column: "reported_by_id"
  add_foreign_key "visitors", "residents"
  add_foreign_key "votes", "poll_options"
  add_foreign_key "votes", "polls"
  add_foreign_key "votes", "users"
end

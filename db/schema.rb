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

ActiveRecord::Schema[7.0].define(version: 2023_03_01_123949) do
  create_table "attendances", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "work_day"
    t.time "start_time"
    t.time "end_time"
    t.boolean "protection", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "work_day"], name: "index_attendances_on_user_id_and_work_day", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "breaks", force: :cascade do |t|
    t.integer "attendance_id", null: false
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id", "start_time"], name: "index_breaks_on_attendance_id_and_start_time"
    t.index ["attendance_id"], name: "index_breaks_on_attendance_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.string "email"
    t.date "hire_date"
    t.date "end_date"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "breaks", "attendances"
end

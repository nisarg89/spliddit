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

ActiveRecord::Schema[7.0].define(version: 2015_04_13_232001) do
  create_table "agents", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "ip_address"
    t.string "passcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "satisfaction"
    t.text "feedback"
    t.integer "instance_id"
    t.boolean "admin"
    t.boolean "submitted", default: false
    t.text "fairness_str"
    t.boolean "mailing_list"
    t.boolean "send_results"
    t.integer "use_results"
  end

  create_table "applications", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "uses", default: 0
    t.string "abbr"
    t.integer "instances_count", default: 0
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "agent_id"
    t.integer "resource_id"
    t.integer "instance_id"
    t.float "ownership"
    t.float "price"
    t.integer "order"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "instances", force: :cascade do |t|
    t.boolean "init_email_sent", default: false
    t.boolean "results_email_sent", default: false
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rent", limit: 10
    t.integer "application_id"
    t.boolean "separate_passwords", default: false
    t.string "name"
    t.string "status", default: "waiting"
    t.string "currency"
    t.string "passcode"
    t.string "admin_email"
    t.string "pickup_address"
    t.float "total_fare"
    t.string "error_message"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.string "rtype"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "instance_id"
    t.integer "quantity"
  end

  create_table "valuations", force: :cascade do |t|
    t.integer "agent_id"
    t.integer "resource_id"
    t.integer "instance_id"
    t.float "value"
  end

end

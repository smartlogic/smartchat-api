# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140314183039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "devices", force: true do |t|
    t.integer  "user_id"
    t.string   "device_id"
    t.string   "device_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", force: true do |t|
    t.integer "from_id", null: false
    t.integer "to_id",   null: false
  end

  add_index "friends", ["from_id", "to_id"], name: "index_friends_on_from_id_and_to_id", unique: true, using: :btree

  create_table "smarches", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.json     "document"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                 null: false
    t.string   "password_hash",         null: false
    t.string   "phone_number"
    t.text     "private_key",           null: false
    t.text     "public_key",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "sms_verification_code"
  end

end

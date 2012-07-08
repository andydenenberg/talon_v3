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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120707182123) do

  create_table "sites", :force => true do |t|
    t.string    "url"
    t.integer   "interval"
    t.string    "active"
    t.string    "status"
    t.float     "delay"
    t.string    "content"
    t.string    "watcher"
    t.timestamp "last_checked"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "next_check"
    t.integer   "down_count"
  end

  create_table "time_logs", :force => true do |t|
    t.integer   "site_id"
    t.timestamp "checked"
    t.string    "status"
    t.float     "delay"
    t.string    "watcher"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "time_logs", ["site_id"], :name => "index_time_logs_on_site_id"

  create_table "users", :force => true do |t|
    t.string    "email",                                 :default => "", :null => false
    t.string    "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                         :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "confirmation_token"
    t.datetime  "confirmed_at"
    t.datetime  "confirmation_sent_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

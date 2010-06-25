# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100620153441) do

  create_table "change_logs", :force => true do |t|
    t.text     "json",        :null => false
    t.string   "record_type", :null => false
    t.integer  "record_id",   :null => false
    t.integer  "user_id",     :null => false
    t.datetime "changed_at",  :null => false
    t.datetime "created_at",  :null => false
  end

  add_index "change_logs", ["record_type", "record_id"], :name => "index_change_logs_on_record_type_and_record_id"

  create_table "credentials", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "identifier", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credentials", ["identifier"], :name => "index_credentials_on_identifier", :unique => true

  create_table "items", :force => true do |t|
    t.text     "content",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    :null => false
  end

  create_table "listings", :force => true do |t|
    t.integer  "list_id",                   :null => false
    t.integer  "item_id",                   :null => false
    t.integer  "position",   :default => 0, :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                   :null => false
  end

  add_index "listings", ["list_id", "item_id"], :name => "index_listings_on_list_id_and_item_id", :unique => true

  create_table "lists", :force => true do |t|
    t.string   "name",                        :null => false
    t.integer  "position",   :default => 999, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "salt",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["salt"], :name => "index_users_on_salt", :unique => true

end

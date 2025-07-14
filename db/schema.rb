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

ActiveRecord::Schema[8.0].define(version: 2025_07_13_143840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "chats", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_notes", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.string "hubspot_id"
    t.text "body"
    t.vector "embedding", limit: 768
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at_hubspot"
    t.datetime "updated_at_hubspot"
    t.index ["contact_id"], name: "index_contact_notes_on_contact_id"
    t.index ["user_id"], name: "index_contact_notes_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "hubspot_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at_hubspot"
    t.datetime "updated_at_hubspot"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "email_embeddings", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.vector "embedding", limit: 1536, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id"], name: "index_email_embeddings_on_email_id", unique: true
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "gmail_id"
    t.string "subject"
    t.string "sender"
    t.text "snippet"
    t.text "body"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "embedding", limit: 768
    t.index ["embedding"], name: "index_emails_on_embedding", opclass: :vector_cosine_ops, using: :ivfflat
    t.index ["user_id"], name: "index_emails_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.string "role"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "rules", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "condition"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_rules_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "google_token"
    t.string "google_refresh_token"
    t.datetime "token_expires_at"
    t.string "hubspot_access_token"
    t.string "hubspot_refresh_token"
    t.datetime "hubspot_token_expires_at"
    t.datetime "google_token_expires_at"
    t.string "google_access_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "contact_notes", "contacts"
  add_foreign_key "contact_notes", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "email_embeddings", "emails"
  add_foreign_key "emails", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "rules", "users"
end

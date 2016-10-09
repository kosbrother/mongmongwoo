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

ActiveRecord::Schema.define(version: 20161009021610) do

  create_table "admin_cart_items", force: :cascade do |t|
    t.integer  "admin_cart_id",        limit: 4
    t.integer  "item_id",              limit: 4
    t.integer  "item_spec_id",         limit: 4
    t.integer  "item_quantity",        limit: 4, default: 0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "actual_item_quantity", limit: 4, default: 0
  end

  add_index "admin_cart_items", ["admin_cart_id"], name: "index_admin_cart_items_on_admin_cart_id", using: :btree
  add_index "admin_cart_items", ["item_id"], name: "index_admin_cart_items_on_item_id", using: :btree
  add_index "admin_cart_items", ["item_spec_id"], name: "index_admin_cart_items_on_item_spec_id", using: :btree

  create_table "admin_carts", force: :cascade do |t|
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "taobao_supplier_id", limit: 4
    t.integer  "status",             limit: 4,   default: 0
    t.string   "note",               limit: 255
    t.datetime "ordered_on"
    t.datetime "confirmed_on"
    t.string   "taobao_order_id",    limit: 255
  end

  add_index "admin_carts", ["taobao_order_id"], name: "index_admin_carts_on_taobao_order_id", using: :btree
  add_index "admin_carts", ["taobao_supplier_id"], name: "index_admin_carts_on_taobao_supplier_id", using: :btree

  create_table "admins", force: :cascade do |t|
    t.string  "username",        limit: 255
    t.string  "password_digest", limit: 255
    t.integer "role",            limit: 4
  end

  create_table "android_versions", force: :cascade do |t|
    t.string  "version_name",   limit: 255
    t.integer "version_code",   limit: 4
    t.text    "update_message", limit: 65535
  end

  create_table "banners", force: :cascade do |t|
    t.integer  "bannerable_id",   limit: 4
    t.string   "bannerable_type", limit: 255
    t.string   "title",           limit: 255
    t.string   "image",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "banners", ["bannerable_type", "bannerable_id"], name: "index_banners_on_bannerable_type_and_bannerable_id", using: :btree

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id",       limit: 4
    t.integer  "item_id",       limit: 4
    t.integer  "item_spec_id",  limit: 4
    t.integer  "item_quantity", limit: 4, default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["item_id"], name: "index_cart_items_on_item_id", using: :btree
  add_index "cart_items", ["item_spec_id"], name: "index_cart_items_on_item_spec_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "shopping_point_amount", limit: 4, default: 0
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "ship_type",             limit: 4, default: 0
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "slug",       limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image",      limit: 255
    t.integer  "parent_id",  limit: 4
    t.integer  "position",   limit: 4,   default: 1
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true, using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_id",           limit: 255, null: false
    t.string   "data_filename",     limit: 255, null: false
    t.integer  "data_size",         limit: 4
    t.string   "data_content_type", limit: 255
    t.integer  "assetable_id",      limit: 4
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "cost_statistics", force: :cascade do |t|
    t.integer  "cost_of_goods",       limit: 4
    t.integer  "cost_of_advertising", limit: 4
    t.integer  "cost_of_freight_in",  limit: 4
    t.date     "cost_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "cost_statistics", ["cost_date"], name: "index_cost_statistics_on_cost_date", using: :btree

  create_table "counties", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "cityid",     limit: 255
    t.integer  "store_type", limit: 4
  end

  add_index "counties", ["cityid"], name: "index_counties_on_cityid", using: :btree
  add_index "counties", ["store_type"], name: "index_counties_on_store_type", using: :btree

  create_table "device_registrations", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "registration_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_registrations", ["registration_id"], name: "index_device_registrations_on_registration_id", using: :btree
  add_index "device_registrations", ["user_id"], name: "index_device_registrations_on_user_id", using: :btree

  create_table "favorite_items", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "item_id",       limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "favorite_type", limit: 4, default: 0
    t.integer  "item_spec_id",  limit: 4
    t.datetime "deleted_at"
  end

  add_index "favorite_items", ["favorite_type"], name: "index_favorite_items_on_favorite_type", using: :btree
  add_index "favorite_items", ["item_id"], name: "index_favorite_items_on_item_id", using: :btree
  add_index "favorite_items", ["item_spec_id"], name: "index_favorite_items_on_item_spec_id", using: :btree
  add_index "favorite_items", ["user_id"], name: "index_favorite_items_on_user_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",   limit: 4,   null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "item_categories", force: :cascade do |t|
    t.integer  "item_id",     limit: 4
    t.integer  "category_id", limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "position",    limit: 4, default: 1000
  end

  add_index "item_categories", ["category_id"], name: "index_item_categories_on_category_id", using: :btree
  add_index "item_categories", ["deleted_at"], name: "index_item_categories_on_deleted_at", using: :btree
  add_index "item_categories", ["item_id"], name: "index_item_categories_on_item_id", using: :btree
  add_index "item_categories", ["position"], name: "index_item_categories_on_position", using: :btree

  create_table "item_promotions", force: :cascade do |t|
    t.integer  "item_id",      limit: 4
    t.integer  "promotion_id", limit: 4
    t.date     "ending_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_promotions", ["ending_on"], name: "index_item_promotions_on_ending_on", using: :btree
  add_index "item_promotions", ["item_id"], name: "index_item_promotions_on_item_id", using: :btree
  add_index "item_promotions", ["promotion_id"], name: "index_item_promotions_on_promotion_id", using: :btree

  create_table "item_specs", force: :cascade do |t|
    t.integer  "item_id",             limit: 4
    t.string   "style",               limit: 255
    t.integer  "style_amount",        limit: 4
    t.string   "style_pic",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "status",              limit: 4,   default: 0
    t.integer  "recommend_stock_num", limit: 4,   default: 3
    t.string   "shelf_position",      limit: 255
    t.boolean  "is_stop_recommend",               default: false
    t.integer  "alert_stock_num",     limit: 4,   default: 1
  end

  add_index "item_specs", ["deleted_at"], name: "index_item_specs_on_deleted_at", using: :btree
  add_index "item_specs", ["item_id"], name: "index_item_specs_on_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",               limit: 255,                                            null: false
    t.integer  "price",              limit: 4,                                              null: false
    t.string   "slug",               limit: 255
    t.integer  "status",             limit: 4,                              default: 1
    t.datetime "deleted_at"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.text     "description",        limit: 65535
    t.string   "cover",              limit: 255
    t.string   "url",                limit: 255
    t.integer  "taobao_supplier_id", limit: 4
    t.decimal  "cost",                             precision: 10, scale: 2
    t.integer  "special_price",      limit: 4
    t.string   "shelf_position",     limit: 255
    t.string   "taobao_name",        limit: 255
    t.text     "note",               limit: 65535
    t.boolean  "ever_on_shelf",                                             default: false
  end

  add_index "items", ["deleted_at"], name: "index_items_on_deleted_at", using: :btree
  add_index "items", ["ever_on_shelf"], name: "index_items_on_ever_on_shelf", using: :btree
  add_index "items", ["slug"], name: "index_items_on_slug", unique: true, using: :btree
  add_index "items", ["taobao_supplier_id"], name: "index_items_on_taobao_supplier_id", using: :btree

  create_table "logins", force: :cascade do |t|
    t.string  "provider",  limit: 255
    t.integer "user_id",   limit: 4
    t.string  "uid",       limit: 255
    t.string  "user_name", limit: 255
    t.string  "gender",    limit: 255
  end

  add_index "logins", ["provider"], name: "index_logins_on_provider", using: :btree
  add_index "logins", ["uid"], name: "index_logins_on_uid", using: :btree
  add_index "logins", ["user_id"], name: "index_logins_on_user_id", using: :btree

  create_table "mail_records", force: :cascade do |t|
    t.integer  "recordable_id",   limit: 4
    t.string   "recordable_type", limit: 255
    t.integer  "mail_type",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "mail_records", ["mail_type"], name: "index_mail_records_on_mail_type", using: :btree
  add_index "mail_records", ["recordable_id"], name: "index_mail_records_on_recordable_id", using: :btree
  add_index "mail_records", ["recordable_type"], name: "index_mail_records_on_recordable_type", using: :btree

  create_table "message_records", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "message_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_records", ["message_id"], name: "index_message_records_on_message_id", using: :btree
  add_index "message_records", ["user_id"], name: "index_message_records_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message_type",     limit: 255
    t.text     "title",            limit: 65535
    t.text     "content",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "messageable_id",   limit: 4
    t.string   "messageable_type", limit: 255
  end

  add_index "messages", ["message_type"], name: "index_messages_on_message_type", using: :btree
  add_index "messages", ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "item_id",       limit: 4
    t.text     "content_title", limit: 65535
    t.text     "content_text",  limit: 65535
    t.string   "content_pic",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id",   limit: 4
  end

  add_index "notifications", ["category_id"], name: "index_notifications_on_category_id", using: :btree
  add_index "notifications", ["item_id"], name: "index_notifications_on_item_id", using: :btree

  create_table "order_blacklists", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_blacklists", ["email"], name: "index_order_blacklists_on_email", using: :btree
  add_index "order_blacklists", ["phone"], name: "index_order_blacklists_on_phone", using: :btree

  create_table "order_infos", force: :cascade do |t|
    t.integer  "order_id",        limit: 4
    t.string   "ship_name",       limit: 255
    t.string   "ship_address",    limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "ship_store_code", limit: 255
    t.string   "ship_phone",      limit: 255
    t.integer  "ship_store_id",   limit: 4
    t.string   "ship_store_name", limit: 255
    t.string   "ship_email",      limit: 255
  end

  add_index "order_infos", ["order_id"], name: "index_order_infos_on_order_id", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",       limit: 4
    t.integer  "item_quantity",  limit: 4
    t.string   "item_name",      limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "item_price",     limit: 4
    t.string   "item_style",     limit: 255
    t.integer  "source_item_id", limit: 4
    t.integer  "item_spec_id",   limit: 4
    t.boolean  "restock",                    default: false
    t.datetime "deleted_at"
  end

  add_index "order_items", ["deleted_at"], name: "index_order_items_on_deleted_at", using: :btree
  add_index "order_items", ["item_spec_id"], name: "index_order_items_on_item_spec_id", using: :btree
  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["source_item_id"], name: "index_order_items_on_source_item_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.integer  "total",                  limit: 4,   default: 0
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "status",                 limit: 4,   default: 0
    t.string   "uid",                    limit: 255
    t.integer  "ship_fee",               limit: 4
    t.integer  "items_price",            limit: 4,   default: 0
    t.string   "note",                   limit: 255, default: ""
    t.integer  "device_registration_id", limit: 4
    t.integer  "logistics_status_code",  limit: 4
    t.integer  "allpay_transfer_id",     limit: 4
    t.boolean  "restock",                            default: false
    t.boolean  "is_repurchased",                     default: false
    t.boolean  "is_blacklisted",                     default: false
    t.integer  "ship_type",              limit: 4,   default: 0
    t.boolean  "is_paid",                            default: false
  end

  add_index "orders", ["logistics_status_code"], name: "index_orders_on_logistics_status_code", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "item_id",     limit: 4
    t.string   "image",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_intro", limit: 255
    t.integer  "position",    limit: 4,   default: 0
  end

  add_index "photos", ["deleted_at"], name: "index_photos_on_deleted_at", using: :btree

  create_table "price_records", force: :cascade do |t|
    t.integer  "item_id",       limit: 4
    t.integer  "price",         limit: 4
    t.integer  "special_price", limit: 4
    t.datetime "changed_at"
  end

  create_table "promotions", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "content",    limit: 255
    t.decimal  "discount",               precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image",      limit: 255
  end

  create_table "roads", force: :cascade do |t|
    t.integer  "town_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "store_type", limit: 4
  end

  add_index "roads", ["store_type"], name: "index_roads_on_store_type", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.integer  "scheduleable_id",   limit: 4
    t.string   "scheduleable_type", limit: 255
    t.datetime "execute_time"
    t.boolean  "is_execute",                    default: false
    t.string   "schedule_type",     limit: 255
    t.string   "job_id",            limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "schedules", ["scheduleable_type", "scheduleable_id"], name: "index_schedules_on_scheduleable_type_and_scheduleable_id", using: :btree

  create_table "shop_infos", force: :cascade do |t|
    t.string   "question",   limit: 255
    t.string   "answer",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "shopping_point_campaigns", force: :cascade do |t|
    t.string   "description", limit: 255
    t.integer  "amount",      limit: 4
    t.datetime "valid_until"
    t.boolean  "is_expired",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",       limit: 255
    t.boolean  "is_reusable",             default: false
  end

  add_index "shopping_point_campaigns", ["is_expired"], name: "index_shopping_point_campaigns_on_is_expired", using: :btree
  add_index "shopping_point_campaigns", ["valid_until"], name: "index_shopping_point_campaigns_on_valid_until", using: :btree

  create_table "shopping_point_records", force: :cascade do |t|
    t.integer  "shopping_point_id", limit: 4
    t.integer  "order_id",          limit: 4
    t.integer  "amount",            limit: 4
    t.integer  "balance",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shopping_point_records", ["order_id"], name: "index_shopping_point_records_on_order_id", using: :btree
  add_index "shopping_point_records", ["shopping_point_id"], name: "index_shopping_point_records_on_shopping_point_id", using: :btree

  create_table "shopping_points", force: :cascade do |t|
    t.integer  "user_id",                    limit: 4
    t.integer  "point_type",                 limit: 4
    t.integer  "amount",                     limit: 4, default: 0,    null: false
    t.datetime "valid_until"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shopping_point_campaign_id", limit: 4
    t.boolean  "is_valid",                             default: true
  end

  add_index "shopping_points", ["is_valid"], name: "index_shopping_points_on_is_valid", using: :btree
  add_index "shopping_points", ["point_type"], name: "index_shopping_points_on_point_type", using: :btree
  add_index "shopping_points", ["shopping_point_campaign_id"], name: "index_shopping_points_on_shopping_point_campaign_id", using: :btree
  add_index "shopping_points", ["user_id"], name: "index_shopping_points_on_user_id", using: :btree

  create_table "stock_specs", force: :cascade do |t|
    t.integer  "item_spec_id", limit: 4
    t.integer  "amount",       limit: 4, default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "item_id",      limit: 4
  end

  add_index "stock_specs", ["item_id"], name: "index_stock_specs_on_item_id", using: :btree
  add_index "stock_specs", ["item_spec_id"], name: "index_stock_specs_on_item_spec_id", using: :btree

  create_table "stores", force: :cascade do |t|
    t.integer  "county_id",  limit: 4
    t.integer  "town_id",    limit: 4
    t.integer  "road_id",    limit: 4
    t.integer  "store_type", limit: 4
    t.string   "store_code", limit: 255
    t.string   "name",       limit: 255
    t.string   "address",    limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.decimal  "lat",                    precision: 9,  scale: 7
    t.decimal  "lng",                    precision: 10, scale: 7
    t.datetime "deleted_at"
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "taobao_suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "towns", force: :cascade do |t|
    t.integer  "county_id",  limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "store_type", limit: 4
  end

  add_index "towns", ["store_type"], name: "index_towns_on_store_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "user_name",              limit: 255
    t.string   "gender",                 limit: 255
    t.string   "uid",                    limit: 255
    t.integer  "status",                 limit: 4,   default: 1
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  limit: 255
    t.string   "password_digest",        limit: 255
    t.string   "password_reset_token",   limit: 255
    t.datetime "password_reset_sent_at"
    t.boolean  "is_mmw_registered",                  default: false
    t.string   "pic_url",                limit: 255
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["password_digest"], name: "index_users_on_password_digest", using: :btree

end

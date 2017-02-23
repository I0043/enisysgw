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

ActiveRecord::Schema.define(version: 20150713130200) do

  create_table "access_logs", id: false, force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "user_code",       limit: 255
    t.string   "user_name",       limit: 255
    t.string   "controller_name", limit: 255
    t.string   "action_name",     limit: 255
    t.text     "parameters",      limit: 65535
    t.string   "feature_id",      limit: 255
    t.string   "feature_name",    limit: 255
    t.string   "ipaddress",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_logs", ["created_at"], name: "index_access_logs_on_created_at", using: :btree

  create_table "doclibrary_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "doclibrary_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.integer  "addnew_forbidden",                        limit: 4
    t.integer  "draft_forbidden",                         limit: 4
    t.integer  "delete_forbidden",                        limit: 4
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_folder",                          limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.integer  "notification",                            limit: 4
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "special_link",                            limit: 65535
    t.datetime "docslast_updated_at"
  end

  create_table "doclibrary_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "one_line_note",      limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.string   "form_name",          limit: 255
    t.text     "inpfld_001",         limit: 65535
    t.integer  "inpfld_002",         limit: 4
    t.integer  "inpfld_003",         limit: 4
    t.integer  "inpfld_004",         limit: 4
    t.integer  "inpfld_005",         limit: 4
    t.integer  "inpfld_006",         limit: 4
    t.text     "inpfld_007",         limit: 65535
    t.text     "inpfld_008",         limit: 65535
    t.text     "inpfld_009",         limit: 65535
    t.text     "inpfld_010",         limit: 65535
    t.text     "inpfld_011",         limit: 65535
    t.text     "inpfld_012",         limit: 65535
    t.text     "notes_001",          limit: 65535
    t.text     "notes_002",          limit: 65535
    t.text     "notes_003",          limit: 65535
  end

  add_index "doclibrary_docs", ["category1_id"], name: "category1_id", using: :btree
  add_index "doclibrary_docs", ["state", "title_id", "category1_id"], name: "title_id", length: {"state"=>50, "title_id"=>nil, "category1_id"=>nil}, using: :btree
  add_index "doclibrary_docs", ["title_id"], name: "title_id2", using: :btree

  create_table "doclibrary_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  create_table "doclibrary_folder_acls", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id",        limit: 4
    t.integer  "title_id",         limit: 4
    t.integer  "acl_flag",         limit: 4
    t.integer  "acl_section_id",   limit: 4
    t.string   "acl_section_code", limit: 255
    t.text     "acl_section_name", limit: 65535
    t.integer  "acl_user_id",      limit: 4
    t.string   "acl_user_code",    limit: 255
    t.text     "acl_user_name",    limit: 65535
  end

  add_index "doclibrary_folder_acls", ["acl_section_code"], name: "acl_section_code", using: :btree
  add_index "doclibrary_folder_acls", ["acl_user_code"], name: "acl_user_code", using: :btree
  add_index "doclibrary_folder_acls", ["folder_id"], name: "folder_id", using: :btree
  add_index "doclibrary_folder_acls", ["title_id"], name: "title_id", using: :btree

  create_table "doclibrary_folders", force: :cascade do |t|
    t.integer  "unid",                 limit: 4
    t.integer  "parent_id",            limit: 4
    t.text     "state",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",             limit: 4
    t.integer  "sort_no",              limit: 4
    t.integer  "level_no",             limit: 4
    t.integer  "children_size",        limit: 4
    t.integer  "total_children_size",  limit: 4
    t.text     "name",                 limit: 65535
    t.text     "memo",                 limit: 65535
    t.text     "readers",              limit: 65535
    t.text     "readers_json",         limit: 65535
    t.text     "reader_groups",        limit: 65535
    t.text     "reader_groups_json",   limit: 65535
    t.datetime "docs_last_updated_at"
    t.text     "admins",               limit: 65535
    t.text     "admins_json",          limit: 65535
    t.text     "admin_groups",         limit: 65535
    t.text     "admin_groups_json",    limit: 65535
  end

  add_index "doclibrary_folders", ["parent_id"], name: "parent_id", using: :btree
  add_index "doclibrary_folders", ["sort_no"], name: "sort_no", using: :btree
  add_index "doclibrary_folders", ["title_id"], name: "title_id", using: :btree

  create_table "doclibrary_group_folders", force: :cascade do |t|
    t.integer  "unid",                 limit: 4
    t.integer  "parent_id",            limit: 4
    t.text     "state",                limit: 65535
    t.text     "use_state",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",             limit: 4
    t.integer  "sort_no",              limit: 4
    t.integer  "level_no",             limit: 4
    t.integer  "children_size",        limit: 4
    t.integer  "total_children_size",  limit: 4
    t.string   "code",                 limit: 255
    t.text     "name",                 limit: 65535
    t.integer  "sysgroup_id",          limit: 4
    t.integer  "sysparent_id",         limit: 4
    t.text     "readers",              limit: 65535
    t.text     "readers_json",         limit: 65535
    t.text     "reader_groups",        limit: 65535
    t.text     "reader_groups_json",   limit: 65535
    t.datetime "docs_last_updated_at"
  end

  add_index "doclibrary_group_folders", ["code"], name: "code", using: :btree

  create_table "doclibrary_recognizers", force: :cascade do |t|
    t.integer  "unid",          limit: 4
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id",      limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "code",          limit: 255
    t.text     "name",          limit: 65535
    t.datetime "recognized_at"
  end

  create_table "doclibrary_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "doclibrary_view_acl_doc_counts", id: false, force: :cascade do |t|
    t.text    "state",            limit: 65535
    t.integer "title_id",         limit: 4
    t.integer "acl_flag",         limit: 4
    t.string  "acl_section_code", limit: 255
    t.string  "acl_user_code",    limit: 255
    t.string  "section_code",     limit: 255
    t.integer "cnt",              limit: 8,     default: 0, null: false
  end

  create_table "doclibrary_view_acl_docs", id: false, force: :cascade do |t|
    t.integer "id",               limit: 4,     default: 0, null: false
    t.integer "sort_no",          limit: 4
    t.integer "acl_flag",         limit: 4
    t.integer "acl_section_id",   limit: 4
    t.string  "acl_section_code", limit: 255
    t.text    "acl_section_name", limit: 65535
    t.integer "acl_user_id",      limit: 4
    t.string  "acl_user_code",    limit: 255
    t.text    "acl_user_name",    limit: 65535
    t.text    "folder_name",      limit: 65535
  end

  create_table "doclibrary_view_acl_files", id: false, force: :cascade do |t|
    t.text     "docs_state",        limit: 65535
    t.integer  "id",                limit: 4,     default: 0, null: false
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
    t.integer  "category1_id",      limit: 4
    t.string   "section_code",      limit: 255
    t.integer  "acl_flag",          limit: 4
    t.integer  "acl_section_id",    limit: 4
    t.string   "acl_section_code",  limit: 255
    t.text     "acl_section_name",  limit: 65535
    t.integer  "acl_user_id",       limit: 4
    t.string   "acl_user_code",     limit: 255
    t.text     "acl_user_name",     limit: 65535
  end

  create_table "doclibrary_view_acl_folders", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,     default: 0, null: false
    t.integer  "unid",                 limit: 4
    t.integer  "parent_id",            limit: 4
    t.text     "state",                limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id",             limit: 4
    t.integer  "sort_no",              limit: 4
    t.integer  "level_no",             limit: 4
    t.integer  "children_size",        limit: 4
    t.integer  "total_children_size",  limit: 4
    t.text     "name",                 limit: 65535
    t.text     "memo",                 limit: 65535
    t.text     "admins",               limit: 65535
    t.text     "admins_json",          limit: 65535
    t.text     "admin_groups",         limit: 65535
    t.text     "admin_groups_json",    limit: 65535
    t.text     "readers",              limit: 65535
    t.text     "readers_json",         limit: 65535
    t.text     "reader_groups",        limit: 65535
    t.text     "reader_groups_json",   limit: 65535
    t.datetime "docs_last_updated_at"
    t.integer  "acl_flag",             limit: 4
    t.integer  "acl_section_id",       limit: 4
    t.string   "acl_section_code",     limit: 255
    t.text     "acl_section_name",     limit: 65535
    t.integer  "acl_user_id",          limit: 4
    t.string   "acl_user_code",        limit: 255
    t.text     "acl_user_name",        limit: 65535
  end

  create_table "gw_admin_messages", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body",       limit: 65535
    t.integer  "sort_no",    limit: 4
    t.integer  "state",      limit: 4
  end

  create_table "gw_circulars", force: :cascade do |t|
    t.integer  "state",       limit: 4
    t.integer  "uid",         limit: 4
    t.string   "u_code",      limit: 255
    t.integer  "gid",         limit: 4
    t.string   "g_code",      limit: 255
    t.integer  "class_id",    limit: 4
    t.text     "title",       limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished", limit: 4
    t.integer  "is_system",   limit: 4
    t.text     "options",     limit: 65535
    t.text     "body",        limit: 65535
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_circulars", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_circulars", ["state"], name: "state", using: :btree
  add_index "gw_circulars", ["uid"], name: "uid", using: :btree

  create_table "gw_edit_link_piece_csses", force: :cascade do |t|
    t.string   "state",         limit: 255
    t.string   "css_name",      limit: 255
    t.integer  "css_sort_no",   limit: 4,   default: 0
    t.string   "css_class",     limit: 255
    t.integer  "css_type",      limit: 4,   default: 1
    t.datetime "deleted_at"
    t.string   "deleted_user",  limit: 255
    t.string   "deleted_group", limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",  limit: 255
    t.string   "updated_group", limit: 255
    t.datetime "created_at"
    t.string   "created_user",  limit: 255
    t.string   "created_group", limit: 255
  end

  create_table "gw_edit_link_pieces", force: :cascade do |t|
    t.integer  "uid",               limit: 4
    t.integer  "class_created",     limit: 4,     default: 0
    t.string   "published",         limit: 255
    t.string   "state",             limit: 255
    t.integer  "level_no",          limit: 4,     default: 0
    t.integer  "parent_id",         limit: 4,     default: 0
    t.string   "name",              limit: 255
    t.integer  "sort_no",           limit: 4,     default: 0
    t.integer  "tab_keys",          limit: 4,     default: 0
    t.integer  "display_auth_priv", limit: 4
    t.integer  "role_name_id",      limit: 4
    t.text     "display_auth",      limit: 65535
    t.integer  "block_icon_id",     limit: 4
    t.integer  "block_css_id",      limit: 4
    t.text     "link_url",          limit: 65535
    t.text     "remark",            limit: 65535
    t.text     "icon_path",         limit: 65535
    t.string   "link_div_class",    limit: 255
    t.integer  "class_external",    limit: 4,     default: 0
    t.integer  "ssoid",             limit: 4
    t.integer  "class_sso",         limit: 4,     default: 0
    t.string   "field_account",     limit: 255
    t.string   "field_pass",        limit: 255
    t.integer  "css_id",            limit: 4,     default: 0
    t.datetime "deleted_at"
    t.string   "deleted_user",      limit: 255
    t.string   "deleted_group",     limit: 255
    t.datetime "updated_at"
    t.string   "updated_user",      limit: 255
    t.string   "updated_group",     limit: 255
    t.datetime "created_at"
    t.string   "created_user",      limit: 255
    t.string   "created_group",     limit: 255
    t.integer  "location",          limit: 4
  end

  create_table "gw_holidays", force: :cascade do |t|
    t.integer  "creator_uid",        limit: 4
    t.string   "creator_ucode",      limit: 255
    t.text     "creator_uname",      limit: 65535
    t.integer  "creator_gid",        limit: 4
    t.string   "creator_gcode",      limit: 255
    t.text     "creator_gname",      limit: 65535
    t.integer  "title_category_id",  limit: 4
    t.string   "title",              limit: 255
    t.integer  "is_public",          limit: 4
    t.text     "memo",               limit: 65535
    t.integer  "schedule_repeat_id", limit: 4
    t.integer  "dirty_repeat_id",    limit: 4
    t.integer  "no_time_id",         limit: 4
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_holidays", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_memo_users", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_memos", force: :cascade do |t|
    t.integer  "class_id",           limit: 4
    t.integer  "uid",                limit: 4
    t.string   "title",              limit: 255
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished",        limit: 4
    t.integer  "is_system",          limit: 4
    t.string   "fr_group",           limit: 255
    t.string   "fr_user",            limit: 255
    t.integer  "memo_category_id",   limit: 4
    t.string   "memo_category_text", limit: 255
    t.text     "body",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_admin_setting_roles", force: :cascade do |t|
    t.integer  "prop_setting_id", limit: 4
    t.integer  "gid",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_admin_settings", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "type_id",    limit: 4
    t.integer  "span",       limit: 4
    t.integer  "span_limit", limit: 4
    t.integer  "span_hour",  limit: 4
    t.integer  "span_min",   limit: 4
    t.integer  "time_limit", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_group_settings", force: :cascade do |t|
    t.integer  "prop_group_id", limit: 4
    t.integer  "prop_other_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_groups", force: :cascade do |t|
    t.text     "state",      limit: 65535
    t.string   "name",       limit: 255
    t.integer  "sort_no",    limit: 4
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_prop_other_images", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.integer  "idx",           limit: 4
    t.string   "note",          limit: 255
    t.string   "path",          limit: 255
    t.string   "orig_filename", limit: 255
    t.string   "content_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_limits", force: :cascade do |t|
    t.integer  "sort_no",    limit: 4
    t.string   "state",      limit: 255
    t.integer  "gid",        limit: 4
    t.integer  "limit",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_roles", force: :cascade do |t|
    t.integer  "prop_id",    limit: 4
    t.integer  "gid",        limit: 4
    t.string   "auth",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_other_roles", ["prop_id"], name: "prop_id", using: :btree

  create_table "gw_prop_others", force: :cascade do |t|
    t.integer  "sort_no",        limit: 4
    t.string   "name",           limit: 255
    t.integer  "type_id",        limit: 4
    t.text     "state",          limit: 65535
    t.integer  "edit_state",     limit: 4
    t.integer  "delete_state",   limit: 4,     default: 0
    t.integer  "reserved_state", limit: 4,     default: 1
    t.text     "comment",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extra_flag",     limit: 255
    t.text     "extra_data",     limit: 65535
    t.integer  "gid",            limit: 4
    t.string   "gname",          limit: 255
    t.integer  "creator_uid",    limit: 4
    t.integer  "updater_uid",    limit: 4
    t.datetime "d_load_st"
    t.datetime "d_load_ed"
    t.integer  "limit_month",    limit: 4
  end

  create_table "gw_prop_types", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.string   "name",       limit: 255
    t.integer  "sort_no",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_reminders", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.string   "category",            limit: 255
    t.string   "sub_category",        limit: 255
    t.integer  "title_id",            limit: 4
    t.integer  "item_id",             limit: 4
    t.string   "title",               limit: 255
    t.datetime "datetime"
    t.string   "url",                 limit: 255
    t.string   "action",              limit: 255
    t.datetime "seen_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expiration_datetime"
  end

  add_index "gw_reminders", ["user_id"], name: "index_gw_reminders_on_user_id", using: :btree

  create_table "gw_schedule_props", force: :cascade do |t|
    t.integer  "schedule_id",   limit: 4
    t.string   "prop_type",     limit: 255
    t.integer  "prop_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra_data",    limit: 65535
    t.integer  "confirmed_uid", limit: 4
    t.integer  "confirmed_gid", limit: 4
    t.datetime "confirmed_at"
    t.integer  "rented_uid",    limit: 4
    t.integer  "rented_gid",    limit: 4
    t.datetime "rented_at"
    t.integer  "returned_uid",  limit: 4
    t.integer  "returned_gid",  limit: 4
    t.datetime "returned_at"
    t.integer  "cancelled_uid", limit: 4
    t.integer  "cancelled_gid", limit: 4
    t.datetime "cancelled_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_props", ["prop_id"], name: "prop_id", using: :btree
  add_index "gw_schedule_props", ["schedule_id", "prop_type", "prop_id"], name: "schedule_id", using: :btree

  create_table "gw_schedule_public_roles", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_repeats", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_date_at"
    t.datetime "ed_date_at"
    t.datetime "st_time_at"
    t.datetime "ed_time_at"
    t.integer  "class_id",    limit: 4
    t.string   "weekday_ids", limit: 255
  end

  create_table "gw_schedule_users", force: :cascade do |t|
    t.integer  "schedule_id", limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "uid",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_users", ["schedule_id", "class_id", "uid"], name: "schedule_id", using: :btree
  add_index "gw_schedule_users", ["schedule_id"], name: "schedule_id2", using: :btree
  add_index "gw_schedule_users", ["uid"], name: "uid", using: :btree

  create_table "gw_schedules", force: :cascade do |t|
    t.integer  "creator_uid",            limit: 4
    t.string   "creator_ucode",          limit: 255
    t.text     "creator_uname",          limit: 65535
    t.integer  "creator_gid",            limit: 4
    t.string   "creator_gcode",          limit: 255
    t.text     "creator_gname",          limit: 65535
    t.integer  "updater_uid",            limit: 4
    t.string   "updater_ucode",          limit: 255
    t.text     "updater_uname",          limit: 65535
    t.integer  "updater_gid",            limit: 4
    t.string   "updater_gcode",          limit: 255
    t.text     "updater_gname",          limit: 65535
    t.integer  "owner_uid",              limit: 4
    t.string   "owner_ucode",            limit: 255
    t.text     "owner_uname",            limit: 65535
    t.integer  "owner_gid",              limit: 4
    t.string   "owner_gcode",            limit: 255
    t.text     "owner_gname",            limit: 65535
    t.integer  "title_category_id",      limit: 4
    t.string   "title",                  limit: 255
    t.integer  "place_category_id",      limit: 4
    t.string   "place",                  limit: 255
    t.integer  "to_go",                  limit: 4
    t.integer  "is_public",              limit: 4
    t.integer  "is_pr",                  limit: 4
    t.text     "memo",                   limit: 65535
    t.text     "admin_memo",             limit: 65535
    t.integer  "repeat_id",              limit: 4
    t.integer  "schedule_repeat_id",     limit: 4
    t.integer  "dirty_repeat_id",        limit: 4
    t.integer  "no_time_id",             limit: 4
    t.integer  "schedule_parent_id",     limit: 4
    t.integer  "participant_nums_inner", limit: 4
    t.integer  "participant_nums_outer", limit: 4
    t.integer  "check_30_over",          limit: 4
    t.text     "inquire_to",             limit: 65535
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo",                   limit: 4
    t.integer  "allday",                 limit: 4
    t.integer  "guide_state",            limit: 4
    t.integer  "guide_place_id",         limit: 4
    t.text     "guide_place",            limit: 65535
    t.integer  "guide_ed_at",            limit: 4
    t.integer  "event_week",             limit: 4
    t.integer  "event_month",            limit: 4
    t.integer  "delete_state",           limit: 4,     default: 0
  end

  add_index "gw_schedules", ["ed_at"], name: "ed_at", using: :btree
  add_index "gw_schedules", ["schedule_repeat_id"], name: "schedule_repeat_id", using: :btree
  add_index "gw_schedules", ["st_at", "ed_at"], name: "st_at", using: :btree

  create_table "gw_user_properties", force: :cascade do |t|
    t.integer  "class_id",   limit: 4
    t.string   "uid",        limit: 255
    t.string   "name",       limit: 255
    t.string   "type_name",  limit: 255
    t.text     "options",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_year_fiscal_jps", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "fyear",         limit: 65535
    t.text     "fyear_f",       limit: 65535
    t.text     "markjp",        limit: 65535
    t.text     "markjp_f",      limit: 65535
    t.text     "namejp",        limit: 65535
    t.text     "namejp_f",      limit: 65535
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gw_year_mark_jps", force: :cascade do |t|
    t.text     "name",          limit: 65535
    t.text     "mark",          limit: 65535
    t.datetime "start_at"
    t.datetime "updated_at"
    t.text     "updated_user",  limit: 65535
    t.text     "updated_group", limit: 65535
    t.datetime "created_at"
    t.text     "created_user",  limit: 65535
    t.text     "created_group", limit: 65535
  end

  create_table "gwbbs_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "gwbbs_comments", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.text     "content_state",      limit: 65535
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "pname",              limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keyword1",           limit: 65535
    t.text     "keyword2",           limit: 65535
    t.text     "keyword3",           limit: 65535
    t.text     "keywords",           limit: 65535
    t.text     "createdate",         limit: 65535
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "expiry_date"
    t.text     "inpfld_001",         limit: 65535
    t.text     "inpfld_002",         limit: 65535
  end

  create_table "gwbbs_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "doc_body_size_capacity",                  limit: 4
    t.integer  "doc_body_size_currently",                 limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.string   "create_section",                          limit: 255
    t.string   "create_section_flag",                     limit: 255
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_mode",                            limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id",                            limit: 4
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.text     "font_color",                              limit: 65535
    t.integer  "icon_id",                                 limit: 4
    t.text     "icon",                                    limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "one_line_use",                            limit: 4
    t.integer  "notification",                            limit: 4
    t.boolean  "restrict_access"
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "notes_field01",                           limit: 65535
    t.text     "notes_field02",                           limit: 65535
    t.text     "notes_field03",                           limit: 65535
    t.text     "notes_field04",                           limit: 65535
    t.text     "notes_field05",                           limit: 65535
    t.text     "notes_field06",                           limit: 65535
    t.text     "notes_field07",                           limit: 65535
    t.text     "notes_field08",                           limit: 65535
    t.text     "notes_field09",                           limit: 65535
    t.text     "notes_field10",                           limit: 65535
    t.datetime "docslast_updated_at"
  end

  create_table "gwbbs_docs", force: :cascade do |t|
    t.integer  "unid",                    limit: 4
    t.integer  "content_id",              limit: 4
    t.text     "state",                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",                limit: 4
    t.integer  "parent_id",               limit: 4
    t.text     "content_state",           limit: 65535
    t.string   "section_code",            limit: 255
    t.text     "section_name",            limit: 65535
    t.integer  "importance",              limit: 4
    t.integer  "one_line_note",           limit: 4
    t.integer  "title_id",                limit: 4
    t.text     "name",                    limit: 65535
    t.text     "pname",                   limit: 65535
    t.text     "title",                   limit: 65535
    t.text     "head",                    limit: 16777215
    t.text     "body",                    limit: 16777215
    t.text     "note",                    limit: 16777215
    t.integer  "category_use",            limit: 4
    t.integer  "category1_id",            limit: 4
    t.integer  "category2_id",            limit: 4
    t.integer  "category3_id",            limit: 4
    t.integer  "category4_id",            limit: 4
    t.text     "keywords",                limit: 65535
    t.text     "createdate",              limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id",      limit: 20
    t.text     "createrdivision",         limit: 65535
    t.string   "creater_id",              limit: 20
    t.text     "creater",                 limit: 65535
    t.text     "editdate",                limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",       limit: 20
    t.text     "editordivision",          limit: 65535
    t.string   "editor_id",               limit: 20
    t.text     "editor",                  limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile",          limit: 4
    t.string   "form_name",               limit: 255
    t.text     "inpfld_001",              limit: 65535
    t.text     "inpfld_002",              limit: 65535
    t.text     "inpfld_003",              limit: 65535
    t.text     "inpfld_004",              limit: 65535
    t.text     "inpfld_005",              limit: 65535
    t.text     "inpfld_006",              limit: 65535
    t.string   "inpfld_006w",             limit: 255
    t.datetime "inpfld_006d"
    t.text     "inpfld_007",              limit: 65535
    t.text     "inpfld_008",              limit: 65535
    t.text     "inpfld_009",              limit: 65535
    t.text     "inpfld_010",              limit: 65535
    t.text     "inpfld_011",              limit: 65535
    t.text     "inpfld_012",              limit: 65535
    t.text     "inpfld_013",              limit: 65535
    t.text     "inpfld_014",              limit: 65535
    t.text     "inpfld_015",              limit: 65535
    t.text     "inpfld_016",              limit: 65535
    t.text     "inpfld_017",              limit: 65535
    t.text     "inpfld_018",              limit: 65535
    t.text     "inpfld_019",              limit: 65535
    t.text     "inpfld_020",              limit: 65535
    t.text     "inpfld_021",              limit: 65535
    t.text     "inpfld_022",              limit: 65535
    t.text     "inpfld_023",              limit: 65535
    t.text     "inpfld_024",              limit: 65535
    t.text     "inpfld_025",              limit: 65535
    t.integer  "name_type",               limit: 4
    t.string   "name_creater_section_id", limit: 20
    t.text     "name_creater_section",    limit: 65535
    t.string   "name_editor_section_id",  limit: 20
    t.text     "name_editor_section",     limit: 65535
  end

  create_table "gwbbs_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  create_table "gwbbs_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gwbbs_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "gwcircular_adms", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "gwcircular_controls", force: :cascade do |t|
    t.integer  "unid",                                    limit: 4
    t.integer  "content_id",                              limit: 4
    t.text     "state",                                   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published",                       limit: 4
    t.integer  "doc_body_size_capacity",                  limit: 4
    t.integer  "doc_body_size_currently",                 limit: 4
    t.integer  "upload_graphic_file_size_capacity",       limit: 4
    t.string   "upload_graphic_file_size_capacity_unit",  limit: 255
    t.integer  "upload_document_file_size_capacity",      limit: 4
    t.string   "upload_document_file_size_capacity_unit", limit: 255
    t.integer  "upload_graphic_file_size_max",            limit: 4
    t.integer  "upload_document_file_size_max",           limit: 4
    t.decimal  "upload_graphic_file_size_currently",                    precision: 17
    t.decimal  "upload_document_file_size_currently",                   precision: 17
    t.integer  "commission_limit",                        limit: 4
    t.string   "create_section",                          limit: 255
    t.string   "create_section_flag",                     limit: 255
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance",                              limit: 4
    t.string   "form_name",                               limit: 255
    t.text     "banner",                                  limit: 65535
    t.string   "banner_position",                         limit: 255
    t.text     "left_banner",                             limit: 65535
    t.text     "left_menu",                               limit: 65535
    t.string   "left_index_use",                          limit: 1
    t.integer  "left_index_pattern",                      limit: 4
    t.string   "left_index_bg_color",                     limit: 255
    t.string   "default_mode",                            limit: 255
    t.text     "other_system_link",                       limit: 65535
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id",                            limit: 4
    t.text     "wallpaper",                               limit: 65535
    t.text     "css",                                     limit: 65535
    t.text     "font_color",                              limit: 65535
    t.integer  "icon_id",                                 limit: 4
    t.text     "icon",                                    limit: 65535
    t.integer  "sort_no",                                 limit: 4
    t.text     "caption",                                 limit: 65535
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line",                      limit: 4
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line",                       limit: 4
    t.boolean  "group_view"
    t.integer  "one_line_use",                            limit: 4
    t.integer  "notification",                            limit: 4
    t.boolean  "restrict_access"
    t.integer  "upload_system",                           limit: 4
    t.string   "limit_date",                              limit: 255
    t.string   "name",                                    limit: 255
    t.string   "title",                                   limit: 255
    t.integer  "category",                                limit: 4
    t.string   "category1_name",                          limit: 255
    t.string   "category2_name",                          limit: 255
    t.string   "category3_name",                          limit: 255
    t.integer  "recognize",                               limit: 4
    t.text     "createdate",                              limit: 65535
    t.string   "createrdivision_id",                      limit: 20
    t.text     "createrdivision",                         limit: 65535
    t.string   "creater_id",                              limit: 20
    t.text     "creater",                                 limit: 65535
    t.text     "editdate",                                limit: 65535
    t.string   "editordivision_id",                       limit: 20
    t.text     "editordivision",                          limit: 65535
    t.string   "editor_id",                               limit: 20
    t.text     "editor",                                  limit: 65535
    t.integer  "default_limit",                           limit: 4
    t.string   "dbname",                                  limit: 255
    t.text     "admingrps",                               limit: 65535
    t.text     "admingrps_json",                          limit: 65535
    t.text     "adms",                                    limit: 65535
    t.text     "adms_json",                               limit: 65535
    t.text     "dsp_admin_name",                          limit: 65535
    t.text     "editors",                                 limit: 65535
    t.text     "editors_json",                            limit: 65535
    t.text     "readers",                                 limit: 65535
    t.text     "readers_json",                            limit: 65535
    t.text     "sueditors",                               limit: 65535
    t.text     "sueditors_json",                          limit: 65535
    t.text     "sureaders",                               limit: 65535
    t.text     "sureaders_json",                          limit: 65535
    t.text     "help_display",                            limit: 65535
    t.text     "help_url",                                limit: 65535
    t.text     "help_admin_url",                          limit: 65535
    t.text     "notes_field01",                           limit: 65535
    t.text     "notes_field02",                           limit: 65535
    t.text     "notes_field03",                           limit: 65535
    t.text     "notes_field04",                           limit: 65535
    t.text     "notes_field05",                           limit: 65535
    t.text     "notes_field06",                           limit: 65535
    t.text     "notes_field07",                           limit: 65535
    t.text     "notes_field08",                           limit: 65535
    t.text     "notes_field09",                           limit: 65535
    t.text     "notes_field10",                           limit: 65535
    t.datetime "docslast_updated_at"
  end

  create_table "gwcircular_custom_groups", force: :cascade do |t|
    t.integer  "parent_id",          limit: 4
    t.integer  "class_id",           limit: 4
    t.integer  "owner_uid",          limit: 4
    t.integer  "owner_gid",          limit: 4
    t.integer  "updater_uid",        limit: 4
    t.integer  "updater_gid",        limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "name_en",            limit: 65535
    t.integer  "sort_no",            limit: 4
    t.text     "sort_prefix",        limit: 65535
    t.integer  "is_default",         limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
  end

  create_table "gwcircular_docs", force: :cascade do |t|
    t.integer  "unid",               limit: 4
    t.integer  "content_id",         limit: 4
    t.text     "state",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type",           limit: 4
    t.integer  "parent_id",          limit: 4
    t.integer  "target_user_id",     limit: 4
    t.string   "target_user_code",   limit: 20
    t.text     "target_user_name",   limit: 65535
    t.integer  "confirmation",       limit: 4
    t.string   "section_code",       limit: 255
    t.text     "section_name",       limit: 65535
    t.integer  "importance",         limit: 4
    t.integer  "title_id",           limit: 4
    t.text     "name",               limit: 65535
    t.text     "title",              limit: 65535
    t.text     "head",               limit: 16777215
    t.text     "body",               limit: 16777215
    t.text     "note",               limit: 16777215
    t.integer  "category_use",       limit: 4
    t.integer  "category1_id",       limit: 4
    t.integer  "category2_id",       limit: 4
    t.integer  "category3_id",       limit: 4
    t.integer  "category4_id",       limit: 4
    t.text     "keywords",           limit: 65535
    t.integer  "commission_count",   limit: 4
    t.integer  "unread_count",       limit: 4
    t.integer  "already_count",      limit: 4
    t.integer  "draft_count",        limit: 4
    t.text     "createdate",         limit: 65535
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", limit: 20
    t.text     "createrdivision",    limit: 65535
    t.string   "creater_id",         limit: 20
    t.text     "creater",            limit: 65535
    t.text     "editdate",           limit: 65535
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  limit: 20
    t.text     "editordivision",     limit: 65535
    t.string   "editor_id",          limit: 20
    t.text     "editor",             limit: 65535
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile",     limit: 4
    t.text     "reader_groups_json", limit: 16777215
    t.text     "reader_groups",      limit: 16777215
    t.text     "readers_json",       limit: 16777215
    t.text     "readers",            limit: 16777215
    t.integer  "spec_config",        limit: 4
  end

  add_index "gwcircular_docs", ["parent_id"], name: "parent_id", using: :btree
  add_index "gwcircular_docs", ["title_id", "doc_type", "target_user_code", "state", "able_date", "createrdivision_id"], name: "index_for_createrdivision_search", length: {"title_id"=>nil, "doc_type"=>nil, "target_user_code"=>nil, "state"=>20, "able_date"=>nil, "createrdivision_id"=>nil}, using: :btree
  add_index "gwcircular_docs", ["title_id", "doc_type", "target_user_code", "state", "created_at", "able_date"], name: "index_for_monthly_search", length: {"title_id"=>nil, "doc_type"=>nil, "target_user_code"=>nil, "state"=>20, "created_at"=>nil, "able_date"=>nil}, using: :btree

  create_table "gwcircular_files", force: :cascade do |t|
    t.integer  "unid",              limit: 4
    t.integer  "content_id",        limit: 4
    t.text     "state",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id",         limit: 4
    t.integer  "title_id",          limit: 4
    t.string   "content_type",      limit: 255
    t.text     "filename",          limit: 65535
    t.text     "memo",              limit: 65535
    t.integer  "size",              limit: 4
    t.integer  "width",             limit: 4
    t.integer  "height",            limit: 4
    t.integer  "db_file_id",        limit: 4
  end

  create_table "gwcircular_itemdeletes", force: :cascade do |t|
    t.integer  "unid",             limit: 4
    t.integer  "content_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code",       limit: 255
    t.integer  "title_id",         limit: 4
    t.text     "board_title",      limit: 65535
    t.string   "board_state",      limit: 255
    t.string   "board_view_hide",  limit: 255
    t.integer  "board_sort_no",    limit: 4
    t.integer  "public_doc_count", limit: 4
    t.integer  "void_doc_count",   limit: 4
    t.string   "dbname",           limit: 255
    t.string   "limit_date",       limit: 255
    t.string   "board_limit_date", limit: 255
  end

  create_table "gwcircular_roles", force: :cascade do |t|
    t.integer  "unid",       limit: 4
    t.integer  "content_id", limit: 4
    t.datetime "created_at"
    t.integer  "title_id",   limit: 4
    t.string   "role_code",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "user_code",  limit: 255
    t.text     "user_name",  limit: 65535
    t.integer  "group_id",   limit: 4
    t.string   "group_code", limit: 255
    t.text     "group_name", limit: 65535
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "system_admin_logs", force: :cascade do |t|
    t.datetime "created_at"
    t.integer  "user_id",    limit: 4
    t.integer  "item_unid",  limit: 4
    t.text     "controller", limit: 65535
    t.text     "action",     limit: 65535
  end

  create_table "system_custom_group_roles", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",        limit: 4
    t.integer  "custom_group_id", limit: 4
    t.text     "priv_name",       limit: 65535
    t.integer  "user_id",         limit: 4
    t.integer  "class_id",        limit: 4
  end

  add_index "system_custom_group_roles", ["custom_group_id"], name: "custom_group_id", using: :btree
  add_index "system_custom_group_roles", ["group_id"], name: "group_id", using: :btree
  add_index "system_custom_group_roles", ["user_id"], name: "user_id", using: :btree

  create_table "system_custom_groups", force: :cascade do |t|
    t.integer  "parent_id",   limit: 4
    t.integer  "class_id",    limit: 4
    t.integer  "owner_uid",   limit: 4
    t.integer  "owner_gid",   limit: 4
    t.integer  "updater_uid", limit: 4,     null: false
    t.integer  "updater_gid", limit: 4,     null: false
    t.text     "state",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",    limit: 4
    t.text     "name",        limit: 65535
    t.text     "name_en",     limit: 65535
    t.integer  "sort_no",     limit: 4
    t.text     "sort_prefix", limit: 65535
    t.integer  "is_default",  limit: 4
  end

  create_table "system_group_histories", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
  end

  create_table "system_groups", force: :cascade do |t|
    t.integer  "parent_id",    limit: 4
    t.text     "state",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no",     limit: 4
    t.integer  "version_id",   limit: 4
    t.string   "code",         limit: 255
    t.text     "name",         limit: 65535
    t.text     "name_en",      limit: 65535
    t.text     "email",        limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no",      limit: 4
    t.string   "ldap_version", limit: 255
    t.integer  "ldap",         limit: 4
    t.integer  "category",     limit: 4
  end

  create_table "system_ldap_temporaries", force: :cascade do |t|
    t.integer  "parent_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version",           limit: 255
    t.string   "data_type",         limit: 255
    t.string   "code",              limit: 255
    t.string   "sort_no",           limit: 255
    t.text     "name",              limit: 65535
    t.text     "name_en",           limit: 65535
    t.text     "kana",              limit: 65535
    t.text     "email",             limit: 65535
    t.text     "match",             limit: 65535
    t.string   "official_position", limit: 255
    t.string   "assigned_job",      limit: 255
  end

  add_index "system_ldap_temporaries", ["version", "parent_id", "data_type", "sort_no"], name: "version", length: {"version"=>20, "parent_id"=>nil, "data_type"=>20, "sort_no"=>nil}, using: :btree

  create_table "system_login_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_login_logs", ["user_id"], name: "user_id", using: :btree

  create_table "system_priv_names", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.integer  "content_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name", limit: 65535
    t.text     "priv_name",    limit: 65535
    t.integer  "sort_no",      limit: 4
  end

  create_table "system_public_logs", force: :cascade do |t|
    t.datetime "created_at"
    t.integer  "user_id",    limit: 4
    t.integer  "item_unid",  limit: 4
    t.text     "controller", limit: 65535
    t.text     "action",     limit: 65535
  end

  create_table "system_role_groups", force: :cascade do |t|
    t.integer  "system_role_id", limit: 4
    t.string   "role_code",      limit: 255
    t.string   "group_code",     limit: 255
    t.integer  "group_id",       limit: 4
    t.text     "group_name",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_role_groups", ["system_role_id"], name: "index_system_role_groups_on_system_role_id", using: :btree

  create_table "system_role_name_privs", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "priv_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_role_names", force: :cascade do |t|
    t.integer  "unid",         limit: 4
    t.text     "state",        limit: 65535
    t.integer  "content_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name", limit: 65535
    t.text     "table_name",   limit: 65535
    t.integer  "sort_no",      limit: 4
  end

  create_table "system_roles", force: :cascade do |t|
    t.string   "table_name",           limit: 255
    t.string   "priv_name",            limit: 255
    t.integer  "idx",                  limit: 4
    t.integer  "class_id",             limit: 4
    t.string   "uid",                  limit: 255
    t.integer  "priv",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id",         limit: 4
    t.integer  "priv_user_id",         limit: 4
    t.integer  "group_id",             limit: 4
    t.text     "editable_groups_json", limit: 65535
  end

  create_table "system_schedule_roles", force: :cascade do |t|
    t.integer  "target_uid", limit: 4, null: false
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_users", force: :cascade do |t|
    t.string   "air_login_id",              limit: 255
    t.text     "state",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      limit: 255,   null: false
    t.integer  "ldap",                      limit: 4,     null: false
    t.integer  "ldap_version",              limit: 4
    t.text     "auth_no",                   limit: 65535
    t.text     "name",                      limit: 65535
    t.text     "name_en",                   limit: 65535
    t.text     "kana",                      limit: 65535
    t.text     "password",                  limit: 65535
    t.integer  "mobile_access",             limit: 4
    t.string   "mobile_password",           limit: 255
    t.text     "email",                     limit: 65535
    t.string   "official_position",         limit: 255
    t.string   "assigned_job",              limit: 255
    t.text     "remember_token",            limit: 65535
    t.datetime "remember_token_expires_at"
    t.text     "air_token",                 limit: 65535
    t.integer  "sort_no",                   limit: 4
    t.string   "imap_password",             limit: 255
  end

  add_index "system_users", ["code"], name: "unique_user_code", unique: true, using: :btree

  create_table "system_users_custom_groups", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_group_id", limit: 4
    t.integer  "user_id",         limit: 4
    t.text     "title",           limit: 65535
    t.text     "title_en",        limit: 65535
    t.integer  "sort_no",         limit: 4
    t.text     "icon",            limit: 65535
  end

  add_index "system_users_custom_groups", ["custom_group_id"], name: "custom_group_id", using: :btree

  create_table "system_users_group_histories", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  create_table "system_users_groups", primary_key: "rid", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
    t.integer  "job_order",  limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code",  limit: 255
    t.string   "group_code", limit: 255
  end

  create_table "system_users_groups_csvdata", force: :cascade do |t|
    t.string   "state",             limit: 255,   null: false
    t.string   "data_type",         limit: 255,   null: false
    t.integer  "level_no",          limit: 4
    t.integer  "parent_id",         limit: 4,     null: false
    t.string   "parent_code",       limit: 255,   null: false
    t.string   "code",              limit: 255,   null: false
    t.integer  "sort_no",           limit: 4
    t.integer  "ldap",              limit: 4,     null: false
    t.integer  "job_order",         limit: 4
    t.text     "name",              limit: 65535, null: false
    t.text     "name_en",           limit: 65535
    t.text     "kana",              limit: 65535
    t.string   "password",          limit: 255
    t.integer  "mobile_access",     limit: 4
    t.string   "mobile_password",   limit: 255
    t.string   "email",             limit: 255
    t.string   "official_position", limit: 255
    t.string   "assigned_job",      limit: 255
    t.datetime "start_at",                        null: false
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category",          limit: 4
  end

  create_table "system_users_groups_csvdata_profiles", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "user_code",   limit: 255
    t.text     "add_column1", limit: 65535
    t.text     "add_column2", limit: 65535
    t.text     "add_column3", limit: 65535
    t.text     "add_column4", limit: 65535
    t.text     "add_column5", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_users_profile_images", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "user_code",     limit: 255
    t.string   "note",          limit: 255
    t.string   "path",          limit: 255
    t.string   "orig_filename", limit: 255
    t.string   "content_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_users_profile_settings", force: :cascade do |t|
    t.string   "key_name",   limit: 255
    t.string   "name",       limit: 255
    t.integer  "used",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_users_profiles", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "user_code",   limit: 255
    t.text     "add_column1", limit: 65535
    t.text     "add_column2", limit: 65535
    t.text     "add_column3", limit: 65535
    t.text     "add_column4", limit: 65535
    t.text     "add_column5", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

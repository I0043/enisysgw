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

ActiveRecord::Schema.define(:version => 0) do

  create_table "doclibrary_adms", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "doclibrary_controls", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                    :precision => 17, :scale => 0
    t.decimal  "upload_document_file_size_currently",                   :precision => 17, :scale => 0
    t.string   "create_section"
    t.integer  "addnew_forbidden"
    t.integer  "draft_forbidden"
    t.integer  "delete_forbidden"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          :limit => 1
    t.string   "left_index_bg_color"
    t.string   "default_folder"
    t.text     "other_system_link"
    t.text     "wallpaper"
    t.text     "css"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.integer  "notification"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",                              :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",                               :limit => 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "special_link"
    t.datetime "docslast_updated_at"
  end

  create_table "doclibrary_roles", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "gw_admin_messages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.integer  "sort_no"
    t.integer  "state"
  end

  create_table "gw_circulars", :force => true do |t|
    t.integer  "state"
    t.integer  "uid"
    t.string   "u_code"
    t.integer  "gid"
    t.string   "g_code"
    t.integer  "class_id"
    t.text     "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.integer  "is_system"
    t.text     "options"
    t.text     "body"
    t.datetime "deleted_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "gw_circulars", ["ed_at"], :name => "ed_at"
  add_index "gw_circulars", ["state"], :name => "state"
  add_index "gw_circulars", ["uid"], :name => "uid"

  create_table "gw_edit_link_piece_csses", :force => true do |t|
    t.string   "state"
    t.string   "css_name"
    t.integer  "css_sort_no",   :default => 0
    t.string   "css_class"
    t.integer  "css_type",      :default => 1
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  create_table "gw_edit_link_pieces", :force => true do |t|
    t.integer  "uid"
    t.integer  "class_created",     :default => 0
    t.string   "published"
    t.string   "state"
    t.integer  "level_no",          :default => 0
    t.integer  "parent_id",         :default => 0
    t.string   "name"
    t.integer  "sort_no",           :default => 0
    t.integer  "tab_keys",          :default => 0
    t.integer  "display_auth_priv"
    t.integer  "role_name_id"
    t.text     "display_auth"
    t.integer  "block_icon_id"
    t.integer  "block_css_id"
    t.text     "link_url"
    t.text     "remark"
    t.text     "icon_path"
    t.string   "link_div_class"
    t.integer  "class_external",    :default => 0
    t.integer  "ssoid"
    t.integer  "class_sso",         :default => 0
    t.string   "field_account"
    t.string   "field_pass"
    t.integer  "css_id",            :default => 0
    t.datetime "deleted_at"
    t.string   "deleted_user"
    t.string   "deleted_group"
    t.datetime "updated_at"
    t.string   "updated_user"
    t.string   "updated_group"
    t.datetime "created_at"
    t.string   "created_user"
    t.string   "created_group"
  end

  create_table "gw_holidays", :force => true do |t|
    t.integer  "creator_uid"
    t.string   "creator_ucode"
    t.text     "creator_uname"
    t.integer  "creator_gid"
    t.string   "creator_gcode"
    t.text     "creator_gname"
    t.integer  "title_category_id"
    t.string   "title"
    t.integer  "is_public"
    t.text     "memo"
    t.integer  "schedule_repeat_id"
    t.integer  "dirty_repeat_id"
    t.integer  "no_time_id"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_holidays", ["st_at", "ed_at"], :name => "st_at"

  create_table "gw_memo_users", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_memos", :force => true do |t|
    t.integer  "class_id"
    t.integer  "uid"
    t.string   "title"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.integer  "is_finished"
    t.integer  "is_system"
    t.string   "fr_group"
    t.string   "fr_user"
    t.integer  "memo_category_id"
    t.string   "memo_category_text"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_images", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "idx"
    t.string   "note"
    t.string   "path"
    t.string   "orig_filename"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_limits", :force => true do |t|
    t.integer  "sort_no"
    t.string   "state"
    t.integer  "gid"
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_prop_other_roles", :force => true do |t|
    t.integer  "prop_id"
    t.integer  "gid"
    t.string   "auth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gw_prop_other_roles", ["prop_id"], :name => "prop_id"

  create_table "gw_prop_others", :force => true do |t|
    t.string   "sort_no"
    t.string   "name"
    t.integer  "type_id"
    t.text     "state"
    t.integer  "edit_state"
    t.integer  "delete_state",   :default => 0
    t.integer  "reserved_state", :default => 1
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extra_flag"
    t.text     "extra_data"
    t.integer  "gid"
    t.string   "gname"
    t.integer  "creator_uid"
    t.integer  "updater_uid"
  end

  create_table "gw_prop_types", :force => true do |t|
    t.string   "state"
    t.string   "name"
    t.integer  "sort_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "gw_schedule_props", :force => true do |t|
    t.integer  "schedule_id"
    t.string   "prop_type"
    t.integer  "prop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "extra_data"
    t.integer  "confirmed_uid"
    t.integer  "confirmed_gid"
    t.datetime "confirmed_at"
    t.integer  "rented_uid"
    t.integer  "rented_gid"
    t.datetime "rented_at"
    t.integer  "returned_uid"
    t.integer  "returned_gid"
    t.datetime "returned_at"
    t.integer  "cancelled_uid"
    t.integer  "cancelled_gid"
    t.datetime "cancelled_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_props", ["prop_id"], :name => "prop_id"
  add_index "gw_schedule_props", ["schedule_id", "prop_type", "prop_id"], :name => "schedule_id"

  create_table "gw_schedule_public_roles", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_schedule_repeats", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_date_at"
    t.datetime "ed_date_at"
    t.datetime "st_time_at"
    t.datetime "ed_time_at"
    t.integer  "class_id"
    t.string   "weekday_ids"
  end

  create_table "gw_schedule_users", :force => true do |t|
    t.integer  "schedule_id"
    t.integer  "class_id"
    t.integer  "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "st_at"
    t.datetime "ed_at"
  end

  add_index "gw_schedule_users", ["schedule_id", "class_id", "uid"], :name => "schedule_id"
  add_index "gw_schedule_users", ["schedule_id"], :name => "schedule_id2"
  add_index "gw_schedule_users", ["uid"], :name => "uid"

  create_table "gw_schedules", :force => true do |t|
    t.integer  "creator_uid"
    t.string   "creator_ucode"
    t.text     "creator_uname"
    t.integer  "creator_gid"
    t.string   "creator_gcode"
    t.text     "creator_gname"
    t.integer  "updater_uid"
    t.string   "updater_ucode"
    t.text     "updater_uname"
    t.integer  "updater_gid"
    t.string   "updater_gcode"
    t.text     "updater_gname"
    t.integer  "owner_uid"
    t.string   "owner_ucode"
    t.text     "owner_uname"
    t.integer  "owner_gid"
    t.string   "owner_gcode"
    t.text     "owner_gname"
    t.integer  "title_category_id"
    t.string   "title"
    t.integer  "place_category_id"
    t.string   "place"
    t.integer  "to_go"
    t.integer  "is_public"
    t.integer  "is_pr"
    t.text     "memo"
    t.text     "admin_memo"
    t.integer  "repeat_id"
    t.integer  "schedule_repeat_id"
    t.integer  "dirty_repeat_id"
    t.integer  "no_time_id"
    t.integer  "schedule_parent_id"
    t.integer  "participant_nums_inner"
    t.integer  "participant_nums_outer"
    t.integer  "check_30_over"
    t.text     "inquire_to"
    t.datetime "st_at"
    t.datetime "ed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "todo"
    t.integer  "allday"
    t.integer  "guide_state"
    t.integer  "guide_place_id"
    t.text     "guide_place"
    t.integer  "guide_ed_at"
    t.integer  "event_week"
    t.integer  "event_month"
  end

  add_index "gw_schedules", ["ed_at"], :name => "ed_at"
  add_index "gw_schedules", ["schedule_repeat_id"], :name => "schedule_repeat_id"
  add_index "gw_schedules", ["st_at", "ed_at"], :name => "st_at"

  create_table "gw_user_properties", :force => true do |t|
    t.integer  "class_id"
    t.string   "uid"
    t.string   "name"
    t.string   "type_name"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gw_year_fiscal_jps", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "fyear"
    t.text     "fyear_f"
    t.text     "markjp"
    t.text     "markjp_f"
    t.text     "namejp"
    t.text     "namejp_f"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gw_year_mark_jps", :force => true do |t|
    t.text     "name"
    t.text     "mark"
    t.datetime "start_at"
    t.datetime "updated_at"
    t.text     "updated_user"
    t.text     "updated_group"
    t.datetime "created_at"
    t.text     "created_user"
    t.text     "created_group"
  end

  create_table "gwbbs_adms", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "gwbbs_controls", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "doc_body_size_capacity"
    t.integer  "doc_body_size_currently"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                    :precision => 17, :scale => 0
    t.decimal  "upload_document_file_size_currently",                   :precision => 17, :scale => 0
    t.string   "create_section"
    t.string   "create_section_flag"
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          :limit => 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.string   "default_mode"
    t.text     "other_system_link"
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "css"
    t.text     "font_color"
    t.integer  "icon_id"
    t.text     "icon"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "one_line_use"
    t.integer  "notification"
    t.boolean  "restrict_access"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",                              :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",                               :limit => 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "notes_field01"
    t.text     "notes_field02"
    t.text     "notes_field03"
    t.text     "notes_field04"
    t.text     "notes_field05"
    t.text     "notes_field06"
    t.text     "notes_field07"
    t.text     "notes_field08"
    t.text     "notes_field09"
    t.text     "notes_field10"
    t.datetime "docslast_updated_at"
  end

  create_table "gwbbs_itemdeletes", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gwbbs_roles", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "gwcircular_adms", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "gwcircular_controls", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.integer  "default_published"
    t.integer  "doc_body_size_capacity"
    t.integer  "doc_body_size_currently"
    t.integer  "upload_graphic_file_size_capacity"
    t.string   "upload_graphic_file_size_capacity_unit"
    t.integer  "upload_document_file_size_capacity"
    t.string   "upload_document_file_size_capacity_unit"
    t.integer  "upload_graphic_file_size_max"
    t.integer  "upload_document_file_size_max"
    t.decimal  "upload_graphic_file_size_currently",                    :precision => 17, :scale => 0
    t.decimal  "upload_document_file_size_currently",                   :precision => 17, :scale => 0
    t.integer  "commission_limit"
    t.string   "create_section"
    t.string   "create_section_flag"
    t.boolean  "addnew_forbidden"
    t.boolean  "edit_forbidden"
    t.boolean  "draft_forbidden"
    t.boolean  "delete_forbidden"
    t.boolean  "attachfile_index_use"
    t.integer  "importance"
    t.string   "form_name"
    t.text     "banner"
    t.string   "banner_position"
    t.text     "left_banner"
    t.text     "left_menu"
    t.string   "left_index_use",                          :limit => 1
    t.integer  "left_index_pattern"
    t.string   "left_index_bg_color"
    t.string   "default_mode"
    t.text     "other_system_link"
    t.boolean  "preview_mode"
    t.integer  "wallpaper_id"
    t.text     "wallpaper"
    t.text     "css"
    t.text     "font_color"
    t.integer  "icon_id"
    t.text     "icon"
    t.integer  "sort_no"
    t.text     "caption"
    t.boolean  "view_hide"
    t.boolean  "categoey_view"
    t.integer  "categoey_view_line"
    t.boolean  "monthly_view"
    t.integer  "monthly_view_line"
    t.boolean  "group_view"
    t.integer  "one_line_use"
    t.integer  "notification"
    t.boolean  "restrict_access"
    t.integer  "upload_system"
    t.string   "limit_date"
    t.string   "name"
    t.string   "title"
    t.integer  "category"
    t.string   "category1_name"
    t.string   "category2_name"
    t.string   "category3_name"
    t.integer  "recognize"
    t.text     "createdate"
    t.string   "createrdivision_id",                      :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",                              :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",                       :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",                               :limit => 20
    t.text     "editor"
    t.integer  "default_limit"
    t.string   "dbname"
    t.text     "admingrps"
    t.text     "admingrps_json"
    t.text     "adms"
    t.text     "adms_json"
    t.text     "dsp_admin_name"
    t.text     "editors"
    t.text     "editors_json"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "sueditors"
    t.text     "sueditors_json"
    t.text     "sureaders"
    t.text     "sureaders_json"
    t.text     "help_display"
    t.text     "help_url"
    t.text     "help_admin_url"
    t.text     "notes_field01"
    t.text     "notes_field02"
    t.text     "notes_field03"
    t.text     "notes_field04"
    t.text     "notes_field05"
    t.text     "notes_field06"
    t.text     "notes_field07"
    t.text     "notes_field08"
    t.text     "notes_field09"
    t.text     "notes_field10"
    t.datetime "docslast_updated_at"
  end

  create_table "gwcircular_custom_groups", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid"
    t.integer  "updater_gid"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
    t.text     "reader_groups_json", :limit => 16777215
    t.text     "reader_groups",      :limit => 16777215
    t.text     "readers_json",       :limit => 16777215
    t.text     "readers",            :limit => 16777215
  end

  create_table "gwcircular_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.integer  "target_user_id"
    t.string   "target_user_code",   :limit => 20
    t.text     "target_user_name"
    t.integer  "confirmation"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "title_id"
    t.text     "name"
    t.text     "title"
    t.text     "head",               :limit => 16777215
    t.text     "body",               :limit => 16777215
    t.text     "note",               :limit => 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.integer  "commission_count"
    t.integer  "unread_count"
    t.integer  "already_count"
    t.integer  "draft_count"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",         :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",          :limit => 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.text     "reader_groups_json", :limit => 16777215
    t.text     "reader_groups",      :limit => 16777215
    t.text     "readers_json",       :limit => 16777215
    t.text     "readers",            :limit => 16777215
  end

  add_index "gwcircular_docs", ["parent_id"], :name => "parent_id"

  create_table "gwcircular_files", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  create_table "gwcircular_itemdeletes", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_code"
    t.integer  "title_id"
    t.text     "board_title"
    t.string   "board_state"
    t.string   "board_view_hide"
    t.integer  "board_sort_no"
    t.integer  "public_doc_count"
    t.integer  "void_doc_count"
    t.string   "dbname"
    t.string   "limit_date"
    t.string   "board_limit_date"
  end

  create_table "gwcircular_roles", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.integer  "title_id"
    t.string   "role_code"
    t.integer  "user_id"
    t.string   "user_code"
    t.text     "user_name"
    t.integer  "group_id"
    t.string   "group_code"
    t.text     "group_name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "system_admin_logs", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "item_unid"
    t.text     "controller"
    t.text     "action"
  end

  create_table "system_custom_group_roles", :primary_key => "rid", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "custom_group_id"
    t.text     "priv_name"
    t.integer  "user_id"
    t.integer  "class_id"
  end

  add_index "system_custom_group_roles", ["custom_group_id"], :name => "custom_group_id"
  add_index "system_custom_group_roles", ["group_id"], :name => "group_id"
  add_index "system_custom_group_roles", ["user_id"], :name => "user_id"

  create_table "system_custom_groups", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "class_id"
    t.integer  "owner_uid"
    t.integer  "owner_gid"
    t.integer  "updater_uid", :null => false
    t.integer  "updater_gid", :null => false
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.text     "name"
    t.text     "name_en"
    t.integer  "sort_no"
    t.text     "sort_prefix"
    t.integer  "is_default"
  end

  create_table "system_group_histories", :force => true do |t|
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_groups", :force => true do |t|
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level_no"
    t.integer  "version_id"
    t.string   "code"
    t.text     "name"
    t.text     "name_en"
    t.text     "email"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "sort_no"
    t.string   "ldap_version"
    t.integer  "ldap"
  end

  create_table "system_ldap_temporaries", :force => true do |t|
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version"
    t.string   "data_type"
    t.string   "code"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "kana"
    t.text     "email"
    t.text     "match"
    t.string   "official_position"
    t.string   "assigned_job"
  end

  add_index "system_ldap_temporaries", ["version", "parent_id", "data_type", "sort_no"], :name => "version", :length => {"version"=>20, "parent_id"=>nil, "data_type"=>20, "sort_no"=>nil}

  create_table "system_login_logs", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_login_logs", ["user_id"], :name => "user_id"

  create_table "system_priv_names", :force => true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "priv_name"
    t.integer  "sort_no"
  end

  create_table "system_public_logs", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "item_unid"
    t.text     "controller"
    t.text     "action"
  end

  create_table "system_role_name_privs", :force => true do |t|
    t.integer  "role_id"
    t.integer  "priv_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_role_names", :force => true do |t|
    t.integer  "unid"
    t.text     "state"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "display_name"
    t.text     "table_name"
    t.integer  "sort_no"
  end

  create_table "system_roles", :force => true do |t|
    t.string   "table_name"
    t.string   "priv_name"
    t.integer  "idx"
    t.integer  "class_id"
    t.string   "uid"
    t.integer  "priv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_name_id"
    t.integer  "priv_user_id"
    t.integer  "group_id"
  end

  create_table "system_users", :force => true do |t|
    t.string   "air_login_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                      :null => false
    t.integer  "ldap",                      :null => false
    t.integer  "ldap_version"
    t.text     "auth_no"
    t.string   "sort_no"
    t.text     "name"
    t.text     "name_en"
    t.text     "kana"
    t.text     "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.text     "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.text     "remember_token"
    t.datetime "remember_token_expires_at"
    t.text     "air_token"
  end

  add_index "system_users", ["code"], :name => "unique_user_code", :unique => true

  create_table "system_users_custom_groups", :primary_key => "rid", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "custom_group_id"
    t.integer  "user_id"
    t.text     "title"
    t.text     "title_en"
    t.integer  "sort_no"
    t.text     "icon"
  end

  add_index "system_users_custom_groups", ["custom_group_id"], :name => "custom_group_id"

  create_table "system_users_group_histories", :primary_key => "rid", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_groups", :primary_key => "rid", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "job_order"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "user_code"
    t.string   "group_code"
  end

  create_table "system_users_groups_csvdata", :force => true do |t|
    t.string   "state",             :null => false
    t.string   "data_type",         :null => false
    t.integer  "level_no"
    t.integer  "parent_id",         :null => false
    t.string   "parent_code",       :null => false
    t.string   "code",              :null => false
    t.integer  "sort_no"
    t.integer  "ldap",              :null => false
    t.integer  "job_order"
    t.text     "name",              :null => false
    t.text     "name_en"
    t.text     "kana"
    t.string   "password"
    t.integer  "mobile_access"
    t.string   "mobile_password"
    t.string   "email"
    t.string   "official_position"
    t.string   "assigned_job"
    t.datetime "start_at",          :null => false
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gwbbs_comments", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               :limit => 16777215
    t.text     "body",               :limit => 16777215
    t.text     "note",               :limit => 16777215
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keyword1"
    t.text     "keyword2"
    t.text     "keyword3"
    t.text     "keywords"
    t.text     "createdate"
    t.string   "createrdivision_id", :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",         :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.string   "editordivision_id",  :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",          :limit => 20
    t.text     "editor"
    t.datetime "expiry_date"
    t.text     "inpfld_001"
    t.text     "inpfld_002"
  end

  create_table "gwbbs_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               :limit => 16777215
    t.text     "body",               :limit => 16777215
    t.text     "note",               :limit => 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",         :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",          :limit => 20
    t.text     "editor"
    t.datetime "able_date"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.string   "form_name"
    t.text     "inpfld_001"
    t.text     "inpfld_002"
    t.text     "inpfld_003"
    t.text     "inpfld_004"
    t.text     "inpfld_005"
    t.text     "inpfld_006"
    t.string   "inpfld_006w"
    t.datetime "inpfld_006d"
    t.text     "inpfld_007"
    t.text     "inpfld_008"
    t.text     "inpfld_009"
    t.text     "inpfld_010"
    t.text     "inpfld_011"
    t.text     "inpfld_012"
    t.text     "inpfld_013"
    t.text     "inpfld_014"
    t.text     "inpfld_015"
    t.text     "inpfld_016"
    t.text     "inpfld_017"
    t.text     "inpfld_018"
    t.text     "inpfld_019"
    t.text     "inpfld_020"
    t.text     "inpfld_021"
    t.text     "inpfld_022"
    t.text     "inpfld_023"
    t.text     "inpfld_024"
    t.text     "inpfld_025"
  end

  create_table "gwbbs_files", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  create_table "doclibrary_docs", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "doc_type"
    t.integer  "parent_id"
    t.text     "content_state"
    t.string   "section_code"
    t.text     "section_name"
    t.integer  "importance"
    t.integer  "one_line_note"
    t.integer  "title_id"
    t.text     "name"
    t.text     "pname"
    t.text     "title"
    t.text     "head",               :limit => 16777215
    t.text     "body",               :limit => 16777215
    t.text     "note",               :limit => 16777215
    t.integer  "category_use"
    t.integer  "category1_id"
    t.integer  "category2_id"
    t.integer  "category3_id"
    t.integer  "category4_id"
    t.text     "keywords"
    t.text     "createdate"
    t.boolean  "creater_admin"
    t.string   "createrdivision_id", :limit => 20
    t.text     "createrdivision"
    t.string   "creater_id",         :limit => 20
    t.text     "creater"
    t.text     "editdate"
    t.boolean  "editor_admin"
    t.string   "editordivision_id",  :limit => 20
    t.text     "editordivision"
    t.string   "editor_id",          :limit => 20
    t.text     "editor"
    t.datetime "expiry_date"
    t.integer  "attachmentfile"
    t.string   "form_name"
    t.text     "inpfld_001"
    t.integer  "inpfld_002"
    t.integer  "inpfld_003"
    t.integer  "inpfld_004"
    t.integer  "inpfld_005"
    t.integer  "inpfld_006"
    t.text     "inpfld_007"
    t.text     "inpfld_008"
    t.text     "inpfld_009"
    t.text     "inpfld_010"
    t.text     "inpfld_011"
    t.text     "inpfld_012"
    t.text     "notes_001"
    t.text     "notes_002"
    t.text     "notes_003"
  end

  add_index "doclibrary_docs", ["category1_id"], :name => "category1_id"
  add_index "doclibrary_docs", ["state", "title_id", "category1_id"], :name => "title_id", :length => {"state"=>50, "title_id"=>nil, "category1_id"=>nil}
  add_index "doclibrary_docs", ["title_id"], :name => "title_id2"

  create_table "doclibrary_files", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "recognized_at"
    t.datetime "published_at"
    t.datetime "latest_updated_at"
    t.integer  "parent_id"
    t.integer  "title_id"
    t.string   "content_type"
    t.text     "filename"
    t.text     "memo"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "db_file_id"
  end

  create_table "doclibrary_folder_acls", :force => true do |t|
    t.integer  "unid"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id"
    t.integer  "title_id"
    t.integer  "acl_flag"
    t.integer  "acl_section_id"
    t.string   "acl_section_code"
    t.text     "acl_section_name"
    t.integer  "acl_user_id"
    t.string   "acl_user_code"
    t.text     "acl_user_name"
  end

  add_index "doclibrary_folder_acls", ["acl_section_code"], :name => "acl_section_code"
  add_index "doclibrary_folder_acls", ["acl_user_code"], :name => "acl_user_code"
  add_index "doclibrary_folder_acls", ["folder_id"], :name => "folder_id"
  add_index "doclibrary_folder_acls", ["title_id"], :name => "title_id"

  create_table "doclibrary_folders", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.integer  "children_size"
    t.integer  "total_children_size"
    t.text     "name"
    t.text     "memo"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.datetime "docs_last_updated_at"
  end

  add_index "doclibrary_folders", ["parent_id"], :name => "parent_id"
  add_index "doclibrary_folders", ["sort_no"], :name => "sort_no"
  add_index "doclibrary_folders", ["title_id"], :name => "title_id"

  create_table "doclibrary_group_folders", :force => true do |t|
    t.integer  "unid"
    t.integer  "parent_id"
    t.text     "state"
    t.text     "use_state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "title_id"
    t.integer  "sort_no"
    t.integer  "level_no"
    t.integer  "children_size"
    t.integer  "total_children_size"
    t.string   "code"
    t.text     "name"
    t.integer  "sysgroup_id"
    t.integer  "sysparent_id"
    t.text     "readers"
    t.text     "readers_json"
    t.text     "reader_groups"
    t.text     "reader_groups_json"
    t.datetime "docs_last_updated_at"
  end

  add_index "doclibrary_group_folders", ["code"], :name => "code"

  create_table "doclibrary_recognizers", :force => true do |t|
    t.integer  "unid"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "title_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "code"
    t.text     "name"
    t.datetime "recognized_at"
  end

end

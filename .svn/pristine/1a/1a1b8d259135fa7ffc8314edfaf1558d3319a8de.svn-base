# -*- encoding: utf-8 -*-
class Gwbbs::Admin::MakersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message

  layout "admin/template/portal"

  def initialize_scaffold
    @img_path = "public/_common/modules/gwbbs/"
    @system = 'gwbbs'
    @piece_head_title = I18n.t("rumi.bbs.name")
    @side = "setting"
    Page.title = I18n.t("rumi.bbs.name")
    params[:limit] = 100
    return http_error(403) unless @gw_admin
  end

  def index
    if @gw_admin
      sysadm_index
    else
      bbsadm_index
    end
  end

  def show
    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) unless @item
    @admingrps = JsonParser.new.parse(@item.admingrps_json) if @item.admingrps_json
    @adms = JsonParser.new.parse(@item.adms_json) if @item.adms_json
    @editors = JsonParser.new.parse(@item.editors_json) if @item.editors_json
    @readers = JsonParser.new.parse(@item.readers_json) if @item.readers_json
    @sueditors = JsonParser.new.parse(@item.sueditors_json) if @item.sueditors_json
    @sureaders = JsonParser.new.parse(@item.sureaders_json) if @item.sureaders_json
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
    _show @item
  end

  def new
    @item = Gwbbs::Control.new({
      :state => 'public',
      :published_at => Time.now,
      :recognize => 0, #承認機能 使用しない
      :importance => '1', #重要度使用区分 使用する
      :category => '0', #分類使用区分 使用しない
      :left_index_use => '1', #左サイドメニュー
      :left_index_pattern => 0,
      :category1_name => I18n.t("rumi.gwbbs.select_item.category_name"),
      :default_published => 2, #掲載期間初期値2ヶ月
      :doc_body_size_capacity => 50, #記事本文総容量制限初期値50MB
      :doc_body_size_currently => 0, #記事本文現在の利用サイズ初期値0
      :upload_graphic_file_size_capacity => 300, #初期値300MB
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 300,  #初期値300MB
      :upload_document_file_size_capacity_unit => 'MB',
      :upload_graphic_file_size_max => 100, #初期値100MB
      :upload_document_file_size_max => 100, #初期値100MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :sort_no => 0 ,
      :view_hide => 1 ,
      :categoey_view  => false ,  #分類件数表示 使用しない
      :categoey_view_line => 0 ,
      :group_view  => 0 ,
      :help_display => '1' ,  #ヘルプを表示しない
      :create_section_flag => '0' , #掲示板管理者用画面を使用しない
      :upload_system => 3 ,   #添付ファイル機能をpublic配下に保存する設定
      :one_line_use => 1 ,  #１行コメント機能 使用する
      :notification => 0 ,  #記事更新時連絡機能 使用しない
      :restrict_access => 0 ,
      :monthly_view => 0 ,
      :monthly_view_line => 0 ,
      :limit_date => 'none', #期限切れ削除設定 しない
      :banner_position => '',
      :css => '#FFFCF0' ,
      :font_color => '#000000' ,
      :default_limit => '20',
      :default_mode => '' #初期表示状態は使用しない
    })
  end

  def edit
    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.preview_mode = false  if @item.preview_mode.blank?
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
  end

  def create
    @item = Gwbbs::Control.new(item_params)
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code unless Core.user.code.blank?
    @item.creater = Core.user.name unless Core.user.name.blank?
    @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0
    @item.monthly_view_line = 0
    @item.view_hide = 1
    @item.create_section_flag = 0
    @item.default_mode = ''
    @item.form_name = 'form001'
    #
    @item.upload_system = 3

    @item._makers = true
    if @item.preview_mode
      _create @item, :success_redirect_uri => gwbbs_makers_path
    else
      _create @item, :success_redirect_uri => gwbbs_makers_path
    end
  end

  def update
    @item = Gwbbs::Control.find(params[:id])
    @item.attributes = item_params
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.categoey_view_line = 0

    @item._makers = true
    if @item.preview_mode
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    else
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    end
  end

  def destroy
    @item = Gwbbs::Control.find(params[:id])
    begin
    @item.image_delete_all(@img_path) if @item  #画像フォルダ削除
    rescue
    end
    @title = Gwbbs::Control.find(params[:id])
    destroy_docs
    destroy_comments
    destroy_atacched_files
    _destroy @item, :success_redirect_uri => gwbbs_makers_path
  end

  def design_publish
    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) if @item.blank?
    @item.preview_mode = false
    @item._design_publish = true
    _update @item
  end

  def sysadm_index
    item = Gwbbs::Control.where("view_hide = ?", (params[:state] == "HIDE" ? 0 : 1))
    item = item.where("create_section IS NULL") unless params[:state] == "SECTION"
    item = item.where("create_section IS NOT NULL") if params[:state] == "SECTION"
    @items = item.order('sort_no, updated_at DESC').paginate(page: params[:page]).limit(params[:limit])
    _index @items
  end

  def bbsadm_index
    item = Gwbbs::Control.where(state: 'public', view_hide: (params[:state] == "HIDE" ? 0 : 1))
    cond = Condition.new
    cond.and do |d|
      d.or do |d2|
        d2.and "gwbbs_adms.user_id", Core.user.id
      end
      d.or do |d2|
        d2.and "gwbbs_adms.user_id", 0
        d2.and "gwbbs_adms.group_id", Core.user.user_group_parent_ids
      end
    end
    @items = item.where(cond.where).joins("INNER JOIN gwbbs_adms ON gwbbs_controls.id = gwbbs_adms.title_id")
               .order('sort_no, updated_at DESC').group('gwbbs_controls.id')
               .paginate(page: params[:page]).limit(params[:limit])
    _index @items
  end

  def sql_where
    sql = Condition.new
    sql.and "title_id", @item.id
    return sql.where
  end

  def destroy_docs
    Gwbbs::Doc.where(sql_where).destroy_all
  end

  def destroy_comments
    Gwbbs::Comment.where(sql_where).destroy_all
  end

  def destroy_atacched_files
    Gwbbs::File.where(sql_where).destroy_all
  end

private

  def item_params
    params.require(:item)
          .permit(:recognize, :importance, :category, :one_line_use, :notification, :categoey_view, :state, :create_section_flag,
                  :title, :default_limit, :default_mode, :default_published, :limit_date, :doc_body_size_capacity, :upload_graphic_file_size_capacity,
                  :upload_graphic_file_size_capacity_unit, :upload_document_file_size_capacity, :upload_document_file_size_capacity_unit,
                  :upload_graphic_file_size_max, :upload_document_file_size_max, :sort_no, :view_hide, :caption, :left_index_pattern,
                  :group_view, :monthly_view, :monthly_view_line, :admingrps_json, :adms_json, :editors_json, :sueditors_json, :readers_json,
                  :sureaders_json, :help_display, :help_url, :help_admin_url, :form_name, :other_system_link, :left_index_use, :doc_body_size_currently,
                  :upload_graphic_file_size_currently, :upload_document_file_size_currently, :restrict_access, :addnew_forbidden,
                  :edit_forbidden, :draft_forbidden, :delete_forbidden, :notes_field01, :notes_field02, :notes_field03, :notes_field04,
                  :notes_field05, :notes_fiel06, :notes_field07, :notes_field08, :notes_field09, :notes_field10)
  end

end

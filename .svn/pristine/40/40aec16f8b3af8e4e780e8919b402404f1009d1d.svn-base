# -*- encoding: utf-8 -*-
class Gwcircular::Admin::BasicsController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message
  layout "admin/template/portal"

  def pre_dispatch
    @public_uri = "/gwcircular/basics"
    @piece_head_title = t("rumi.config_settings.gwcircular.setting.name")
    @side = "setting"

    Page.title = t("rumi.config_settings.gwcircular.setting.name")
    params[:limit] = 100
    return http_error(403) unless @gw_admin
  end

  def index
    if @gw_admin
      sysadm_index
    else
      circularadm_index
    end
  end

  def show
    @item = Gwcircular::Control.find(params[:id])
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
    @item = Gwcircular::Control.new({
      :state => 'public',
      :published_at => Time.now,
      :recognize => 0,
      :importance => '1', #重要度使用
      :category => '1', #分類使用
      :left_index_use => '1', #左サイドメニュー
      :left_index_pattern => 0,
      :category1_name => I18n.t("rumi.gwbbs.select_item.category_name"),
      :default_published => 3,
      :doc_body_size_capacity => 100, #記事本文総容量制限初期値30MB
      :doc_body_size_currently => 0, #記事本文現在の利用サイズ初期値0
      :upload_graphic_file_size_capacity => 10, #初期値10MB
      :upload_graphic_file_size_capacity_unit => 'GB',
      :upload_document_file_size_capacity => 10,  #初期値30MB
      :upload_document_file_size_capacity_unit => 'GB',
      :upload_graphic_file_size_max => 50, #初期値3MB
      :upload_document_file_size_max => 50, #初期値10MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :commission_limit => 200 ,
      :sort_no => 0 ,
      :view_hide => 1 ,
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :group_view  => 1 ,
      :help_display => '1' ,  #ヘルプを表示しない
      :create_section_flag => 'section_code' , #掲示板管理者用画面を使用する
      :upload_system => 3 ,   #添付ファイル機能をpublic配下に保存する設定
      :one_line_use => 1 ,  #１行コメント使用
      :notification => 1 ,  #記事更新時連絡機能を利用する
      :restrict_access => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :limit_date => 'none',
      :banner_position => '',
      :css => '#FFFCF0' ,
      :font_color => '#000000' ,
      :default_limit => '20'
    })
  end

  def edit
    @item = Gwcircular::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.create_section_flag = 'section_code' if @item.create_section_flag.blank? unless @item.create_section.blank? #実装前に作成された掲示板の対応
    @item.preview_mode = false  if @item.preview_mode.blank?
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
  end

  def create
    @item = Gwcircular::Control.new(item_params)
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
    @item.doc_body_size_capacity = 100
    @item.doc_body_size_currently = 0

    @item.upload_system = 3

    groups = JsonParser.new.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end
    @item._makers = true
    if @item.preview_mode
      _create @item, :success_redirect_uri => 'makers_show'
    else
      _create @item
    end
  end

  def update
    @item = Gwcircular::Control.find(params[:id])
    @item.attributes = item_params
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.categoey_view_line = 0

    groups = JsonParser.new.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end
    @item._makers = true
    _update @item, :success_redirect_uri => @item.adm_show_path
  end

  def destroy
    @item = Gwcircular::Control.find(params[:id])
    begin
      @item.image_delete_all(@img_path) if @item
    rescue
    end
    @title = Gwcircular::Control.find(params[:id])
    _destroy @item
  end

  def design_publish
    @item = Gwcircular::Control.find(params[:id])
    return http_error(404) if @item.blank?
    @item.preview_mode = false
    @item._design_publish = true
    _update @item
  end

  def sysadm_index
    hide = false
    hide = true if params[:state] == "HIDE"
    item = Gwcircular::Control
    if hide
      item = item.where(view_hide: 0)
    else
      item = item.where(view_hide: 1)
    end
    if(params[:state] == "SECTION")
      item = item.where("create_section IS NOT NULL")
    else
      item = item.where("create_section IS NULL")
    end
    @items = item.order('sort_no, updated_at DESC').paginate(page: params[:page]).limit(params[:limit])
    _index @items
  end

  def circularadm_index
    hide = false
    hide = true if params[:state] == "HIDE"

    sql = Condition.new
    sql.or {|d|
      d.and "sql", "gwcircular_controls.state = 'public'"
      d.and "sql", "gwcircular_controls.view_hide = 0" if hide
      d.and "sql", "gwcircular_controls.view_hide = 1" unless hide
      d.and "sql", "gwcircular_adms.user_code = '#{Core.user.code}'"
    }
    cond = ["user_id = ?", Core.user.id]
    user_groups = System::UsersGroup.without_disable.where(cond)
    group_codes = ""
    user_groups.each do |ug|
      group_codes << "," unless group_codes.blank?
      group_codes << ug.group_code.to_s
    end
    sql.or {|d|
      d.and "sql", "gwcircular_controls.state = 'public'"
      d.and "sql", "gwcircular_controls.view_hide = 0" if hide
      d.and "sql", "gwcircular_controls.view_hide = 1" unless hide
      d.and "sql", "gwcircular_adms.user_id = 0"
      d.and "sql", "gwcircular_adms.group_code in (#{group_codes})"
    }
    join = "INNER JOIN gwcircular_adms ON gwcircular_controls.id = gwcircular_adms.title_id"
    @items = Gwcircular::Control.joins(join).where(sql.where).order('sort_no, updated_at DESC').group('gwcircular_controls.id')
                             .paginate(page: params[:page]).limit(params[:limit])
    _index @items
  end

  def sql_where
    sql = Condition.new
    sql.and "title_id", @item.id
    return sql.where
  end

  def destroy_docs
    item = gwcircular_db_alias(Gwcircular::Doc)
    item.where(sql_where).destroy_all
    Gwcircular::Doc.remove_connection
  end

  def destroy_comments
    item = gwcircular_db_alias(Gwcircular::Comment)
    item.where(sql_where).destroy_all
    Gwcircular::Comment.remove_connection
  end

  def destroy_image_files
    item = gwcircular_db_alias(Gwcircular::Image)
    item.where(sql_where).destroy_all
    Gwcircular::Image.remove_connection
  end

  def destroy_atacched_files
    item = gwcircular_db_alias(Gwcircular::File)
    item.where(sql_where).destroy_all
    Gwcircular::File.remove_connection
  end

private

  def item_params
    params.require(:item)
          .permit(:default_limit, :default_published, :commission_limit, :limit_date, :upload_graphic_file_size_max,
                  :upload_document_file_size_max, :admingrps_json, :adms_json, :editors_json, :sueditors_json, :readers_json, :sureaders_json)
  end
end

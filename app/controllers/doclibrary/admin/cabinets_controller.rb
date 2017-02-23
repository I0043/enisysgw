# -*- encoding: utf-8 -*-
class Doclibrary::Admin::CabinetsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Doclibrary::Model::DbnameAlias
  include Rumi::Doclibrary::Authorize
  include Gwboard::Controller::Message

  layout "admin/template/portal"

  def initialize_scaffold
    @img_path = "public/doclibrary/docs/"
    @system = 'doclibrary'
    @cabinet_title = I18n.t('activerecord.models.doclibrary/category')
    Page.title = I18n.t("activerecord.models.doclibrary/category")
    @piece_head_title = I18n.t("rumi.doclibrary.name")
    @side = "setting"
    flag = params[:id].present? ? params[:id] : '_menu'
    admin_flags(flag)
    return http_error(403) unless @doclibrary_admin
  end

  def index
    if @gw_admin
      sysadm_index
    else
      bbsadm_index
    end
  end

  def show
    @item = Doclibrary::Control.find(params[:id])
    return http_error(404) unless @item
    @admingrps = JsonParser.new.parse(@item.admingrps_json) if @item.admingrps_json
    @adms = JsonParser.new.parse(@item.adms_json) if @item.adms_json
    @readers = JsonParser.new.parse(@item.readers_json) if @item.readers_json
    @sureaders = JsonParser.new.parse(@item.sureaders_json) if @item.sureaders_json
    @image_message = ret_image_message
    @document_message = ret_document_message
    _show @item
  end

  def new
    @item = Doclibrary::Control.new({
      :state => 'public' ,
      :published_at => Core.now ,
      :importance => '1' ,
      :category => '1' ,
      :left_index_use => '1',
      category1_name: I18n.t("rumi.doclibrary.rootfolder") ,
      :recognize => '0' ,
      :default_published => 3,
      :upload_graphic_file_size_capacity => 10,
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 30,
      :upload_document_file_size_capacity_unit => 'MB',
      :upload_graphic_file_size_max => 3,
      :upload_document_file_size_max => 10,
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :sort_no => 0 ,
      :view_hide => 1 ,
      :upload_system => 3 ,
      :notification => 1 ,
      :help_display => '1' ,
      :create_section => '' ,
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :default_limit => '20'
    })
  end

  def edit
    @item = Doclibrary::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.notification = 0 if @item.notification.blank?
  end

  def create
    @item = Doclibrary::Control.new(item_params)
    @item.category1_name = @item.title
    @item.notification = 0
    @item.view_hide = true
    @item.left_index_use = '1'
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code unless Core.user.code.blank?
    @item.creater = Core.user.name unless Core.user.name.blank?
    @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.form_name = 'form001'
    @item.create_section = ''
    @item.importance = '1'
    @item.default_folder = 'CATEGORY'
    @item.recognize = '0'

    @item.upload_system = 3
    if @item.save
      redirect_to "/doclibrary/group_folders/sync_groups?title_id=#{@item.id}&mode=public&make=new"
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @item = Doclibrary::Control.find(params[:id])
    @item.attributes = item_params
    @item.category1_name = @item.title
    @item.notification = 0
    @item.view_hide = true
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @title = @item
    _update @item, :success_redirect_uri => doclibrary_cabinet_path(@item)
  end

  def destroy
    @item = Doclibrary::Control.find(params[:id])
    _destroy @item
  end

  def sysadm_index
    @items = Doclibrary::Control.where(view_hide: params[:state] == "HIDE" ? 0 : 1)
                              .order('sort_no, updated_at DESC')
                              .paginate_doclibrary(params)
                              
    _index @items
  end

  def bbsadm_index
    item = Doclibrary::Control.where(state: 'public', view_hide: params[:state] == "HIDE" ? 0 : 1)
    sql = Condition.new

    sql.or do |d2|
      d2.and "doclibrary_adms.user_id", Core.user.id
    end
    sql.or do |d2|
      d2.and "doclibrary_adms.user_id", 0
      d2.and "doclibrary_adms.group_id", Core.user.user_group_parent_ids
    end

    @items = item.where(sql.where).joins("INNER JOIN doclibrary_adms ON doclibrary_controls.id = doclibrary_adms.title_id")
                 .order('sort_no, updated_at DESC').group('doclibrary_controls.id')
                 .paginate_doclibrary(params)
    _index @items
  end

private

  def item_params
    params.require(:item)
          .permit(:state, :create_section, :recognize, :title, :default_limit, :importance, :default_folder,
                  :upload_graphic_file_size_capacity, :upload_graphic_file_size_capacity_unit, :upload_document_file_size_capacity,
                  :upload_document_file_size_capacity_unit, :upload_graphic_file_size_max, :upload_document_file_size_max,
                  :sort_no, :caption, :admingrps_json, :adms_json, :readers_json, :sureaders_json, :banner, :left_banner,
                  :left_index_bg_color, :form_name, :other_system_link, :special_link, :left_index_use, :upload_graphic_file_size_currently,
                  :upload_document_file_size_currently, :help_display, :help_url, :help_admin_url)
  end

end

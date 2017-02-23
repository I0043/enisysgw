# encoding: utf-8
class System::Admin::RolesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  protect_from_forgery :except => [:destroy]
  layout "admin/template/portal"

  def initialize_scaffold
    index_path = system_roles_path
    return redirect_to(index_path) if params[:reset]
    Page.title = t("rumi.role.name")
    @piece_head_title = t("rumi.role.name")
    @side = "setting"
  end

  def index
    init_params
    return authentication_error(403) unless @gw_admin
    @items = System::Role.where(table_name: "_admin", priv_name: "admin")
                         .order(idx: :asc, id: :asc)
                         .paginate(page: params[:page])
                         .limit(nz(params[:limit], 30))
  end

  def show
    init_params
    return authentication_error(403) unless @gw_admin
    @item = System::Role.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @gw_admin
    @item = System::Role.new({
      class_id: '1',
      priv: '1',
      role_name_id: 21,
      priv_user_id: 1,
      table_name: "_admin",
      priv_name: "admin",
      class_id: 1,
      idx: 1,
      priv: 1
    })
    @groups = System::Group.without_root.without_disable.extract_readable_group_in_system_users
  end

  def create
    init_params
    return authentication_error(403) unless @gw_admin
    conv_uidraw_to_uid

    @item = System::Role.new(item_params)
    location = system_roles_path
    options = {
      success_redirect_uri: location
      }
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @gw_admin
    @item = System::Role.find_by(id: params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @gw_admin
    conv_uidraw_to_uid
    @item = System::Role.find(params[:id])
    @item.attributes = item_params
    location = system_roles_path
    options = {
      success_redirect_uri: location
      }
    _update(@item, options)
  end

  def conv_uidraw_to_uid()
    params[:item]['uid'] = ( params[:item]['class_id'] == '1' ? params[:item]['uid_raw'] : params[:item]['gid_raw']) if nz(params[:item]['class_id'],'') != ''
    params[:item]['group_id'] = ( params[:item]['class_id'] == '1' ? params[:item]['gid_raw'] : '') if nz(params[:item]['class_id'],'') != ''
    params[:item].delete 'uid_raw'
    params[:item].delete 'gid_raw'
  end

  def destroy
    init_params
    return authentication_error(403) unless @gw_admin
    @item = System::Role.find(params[:id])
    options = {
      success_redirect_uri: system_roles_path
      }
    _destroy(@item, options)
  end

  def init_params
    @role_id = nz(params[:role_id],'0')
    @priv_id = nz(params[:priv_id],'0')

    search_condition
  end

  def search_condition
    params[:role_id] = nz(params[:role_id], @role_id)

    qsa = ['role_id' , 'priv_id' , 'role' , 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    html_select = ""
    users.each do |value , key|
      html_select << "<option value='#{key}'>#{value}</option>"
    end

    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

private
  def item_params
    params.require(:item)
          .permit(:role_name_id, :priv_user_id, :idx, :class_id, :gid_raw, :uid_raw, :priv, :editable_groups_json, :uid, :group_id)
  end

end

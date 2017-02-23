# encoding: utf-8
class System::Admin::GroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  before_action :creatable_child_group!, only: [:new, :create]
  before_action :editable_group!, only: [:show, :edit, :update, :destroy]
  before_action :readable_group!, only: [:index]

  def initialize_scaffold
    @current_no = 2
    @action = params[:action]
    parent_id = params[:parent].blank? || params[:parent] == '0' ? System::Group.root_id : params[:parent]
    @parent = System::Group.find_by(id: parent_id)
    @parent_groups = System::Group.where(level_no: @parent.level_no, state: 'enabled')

    Page.title = t("rumi.group.name")
    @piece_head_title = t("rumi.group.name")
    @side = "setting"

    @role_admin = System::User.is_admin?
    return authentication_error(403) unless @role_admin
  end

  # === 管理グループに設定された所属、かつ階層レベルが2以上のグループか判断するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  authentication_error(403)
  def creatable_child_group!
    is_creatable_child_group = Core.user.creatable_child_group_in_system_users?(@parent.id)
    return authentication_error(403) unless is_creatable_child_group
  end

  # === 管理グループに設定された所属に含まれるグループか判断するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  authentication_error(403)
  def editable_group!
    is_editable_group = Core.user.editable_group_in_system_users?(params[:id])
    return authentication_error(403) unless is_editable_group
  end

  # === 管理グループに設定された所属 + それらの親グループか判断するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  authentication_error(403)
  def readable_group!
    is_readable_group = Core.user.readable_group_in_system_users?(@parent.id)
    return authentication_error(403) unless is_readable_group
  end

  def index
    items = System::Group.extract_readable_group_in_system_users.where(level_no: 2).order(:sort_no)
    @items = []
    items.each do |item|
      @items << item
      child = System::Group.extract_readable_group_in_system_users.where(level_no: 3, parent_id: item.id).order(:sort_no)
      child.each do |child|
        @items << child
      end
    end
  end

  def show
    @item = System::Group.find_by(id: params[:id])
    _show @item
  end

  def new
    @item = System::Group.new({
        :parent_id    =>  @parent.id,
        :state        =>  'enabled',
        :level_no     =>  @parent.level_no.to_i + 1,
        :version_id   =>  @parent.version_id.to_i,
        :start_at     =>  Time.now.strftime("%Y-%m-%d 00:00:00"),
        :sort_no      =>  @parent.sort_no.to_i ,
        :ldap_version =>  nil,
        :ldap         =>  0,
        :category     =>  0
    })
    @level_no = [['2', '2'],['3', '3']]
    @parent_group_l2 = System::Group.where(level_no: 1, state: 'enabled')
    @parent_group_l3 = System::Group.where(level_no: 2, state: 'enabled')
  end

  def create
    params[:item][:parent_id] = params[:item][:level_no] == "2" ? params[:item][:parent_id_l2] : params[:item][:parent_id_l3]
    @item = System::Group.new(item_params)
    @item.version_id    = @parent.version_id.to_i
    @item.ldap_version  = nil

    @level_no = [['2', '2'],['3', '3']]
    @parent_group_l2 = System::Group.where(level_no: 1, state: 'enabled')
    @parent_group_l3 = System::Group.where(level_no: 2, state: 'enabled')

    _create @item
  end
  
  def edit
    @item = System::Group.find_by(id: params[:id])
    @parent = System::Group.where(id: @item.parent_id).first
    @parent_group = System::Group.where(level_no: @item.level_no - 1, state: 'enabled')
  end

  def update
    @item = System::Group.find_by(id: params[:id])
    @item.attributes = item_params
    @parent = System::Group.where(id: @item.parent_id).first
    @parent_group = System::Group.where(level_no: @item.level_no - 1, state: 'enabled')
    _update @item
  end

  def destroy
    @item = System::Group.find_by(id: params[:id])
    # 所属するユーザーが存在する場合は不可
    # 下位に有効な所属が存在する場合は不可
    if !@item.has_enable_child_or_users_group?
      @item.state  = 'disabled'
      @item.end_at = Time.now.strftime("%Y-%m-%d 00:00:00")
      _update @item, {success_redirect_uri: system_groups_path, notice: t("rumi.message.notice.delete")}
    else
      flash[:notice] = flash[:notice] || t("rumi.group.message.delete_fail")
      redirect_to :action=>'show'
    end
  end

  def item_to_xml(item, options = {})
    options[:include] = [:status]
    xml = ''; xml << item.to_xml(options) do |n|
    end
    return xml
  end

private
  def item_params
    params.require(:item)
          .permit(:parent_id, :level_no, :ldap_version, :version_id, :state, :category, :ldap, :code, :name, :name_en,
                  :email, :sort_no, :start_at, :end_at)
  end

end

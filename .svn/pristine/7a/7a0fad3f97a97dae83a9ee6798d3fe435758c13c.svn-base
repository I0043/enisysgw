# encoding: utf-8
class System::Admin::UsersGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  before_action :editable_group!, only: [:show, :edit, :update, :destroy]
  before_action :readable_group!, only: [:index]
  before_action :set_groups_user, only: [:new, :create, :edit, :update]

  def initialize_scaffold
    Page.title = t("rumi.users_group.name")
    @piece_head_title = t("rumi.users_group.name")
    @side = "setting"

    @role_admin = System::User.is_admin?
    return authentication_error(403) unless @role_admin
  end

  # === 管理グループに設定された所属に含まれるグループか判断するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  authentication_error(403)
  def editable_group!
    users_group = System::UsersGroup.where(rid: params[:id]).first
    is_editable_group = users_group && Core.user.editable_group_in_system_users?(users_group.group_id)
    return authentication_error(403) unless is_editable_group
  end

  # === 管理グループに設定された所属 + それらの親グループか判断するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  authentication_error(403)
  def readable_group!
    unless System::User.is_admin?
      is_readable_group = Core.user.readable_group_in_system_users?(@parent.id)
      return authentication_error(403) unless is_readable_group
    end
  end

  # === 管理グループに設定された所属をセットするメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def set_groups_user
    @groups = System::Group.without_root.without_disable.extract_readable_group_in_system_users
    @disabled_group_ids = Core.user.uneditable_group_ids_in_system_users(@groups)
    @any_group_ids = @groups.extract_any_group.map(&:id)

    # 管理グループに設定された所属に属するユーザーのみ表示する
    @users = System::User.without_disable.extract_editable_user_in_system_users(Core.user.id)
  end

  def index
    # 管理グループが階層レベル3のグループのみの場合は、その親グループは
    # 表示可能だか、ユーザーは閲覧できない。
    if @role_admin
      # 並び順をユーザーのdefault_scopeと同様(ユーザーの並び順 > ユーザーコードの昇順)にする
      @items = System::UsersGroup.unscoped.all.order_user_default_scope
    end
  end

  def show
    @item = System::UsersGroup.where(rid: params[:id]).first
  end

  def new
    @item = System::UsersGroup.new({
      :job_order => 0,
      :start_at  => Time.now
    })

    # 新規作成ボタンをクリックした時の親グループ管理グループでなかったらnilを初期値とする
    unless params[:user_id].nil?
      @item.user_id = params[:user_id]
    end
  end

  def create
    @item = System::UsersGroup.new(item_params)
    _create @item, success_redirect_uri: system_user_path(@item.user_id)
  end

  def edit
    @item = System::UsersGroup.find(params[:id])
  end

  def update
    @item = System::UsersGroup.find(params[:id])
    @item.attributes = item_params
    _update @item, success_redirect_uri: system_users_group_path(@item.rid)
  end

  def destroy
    @item = System::UsersGroup.find(params[:id])
    _destroy @item, success_redirect_uri: system_user_path(@item.user_id)
  end

  def item_to_xml(item, options = {})
    options[:include] = [:user]
    xml = ''; xml << item.to_xml(options) do |n|
    end
    return xml
  end

private
  def item_params
    params.require(:item)
          .permit(:user_id, :group_id, :job_order, :start_at, :end_at)
  end
end

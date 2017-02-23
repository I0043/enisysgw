# encoding: utf-8
class System::Admin::ScheduleRolesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::SchedulesHelper
  protect_from_forgery :except => [:destroy]
  layout "admin/template/portal"

  before_action :set_groups_user, only: [:new, :create, :edit, :update]

  def initialize_scaffold
    index_path = system_roles_path
    return redirect_to(index_path) if params[:reset]
    @piece_head_title = t("rumi.config_settings.schedule_role.name")
    Page.title = t("rumi.config_settings.schedule_role.name")
    @side = "setting"
  end

  def init_params
    @model = System::ScheduleRole
    @disable_users = System::User.without_enable
    @users = System::User.without_disable
    @groups = System::Group.without_disable
  end

  # === 初期値のグループ、ユーザー情報
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def set_groups_user
    @parent_group_id = Core.user_group.parent_id
    @group_child_groups = System::Group.child_groups_to_select_option(@parent_group_id)
  end

  def index
    init_params
    return authentication_error(403) unless @gw_admin

    item = @model
    _items = item.group("target_uid").order("id")

    @items = Array.new
    _items.each do |it|
      target = it.target_uid

      dummy = DummyItem.new
      dummy.id = it.id
      dummy.users = Array.new
      dummy.groups = Array.new

      items = item.where("target_uid = ?", [target]).order("user_id,id")
      items.each do |item|
        @disable_users.each do |u|
          dummy.target = u.name + "（" + t("rumi.state.disabled") + "）" if target == u.id
        end
        @users.each do |user|
          dummy.target = user.name if target == user.id
          dummy.users << user.name if item.user_id == user.id
        end
      end

      items = item.where("target_uid = ?", [target]).order("group_id,id")
      items.each do |item|
        @groups.each do |group|
          dummy.groups << group.name if item.group_id == group.id
        end
      end

      @items << dummy if dummy.target.present?
    end
  end

  def show
    init_params
    users = System::User.without_disable
    item = @model.find_by(id: params[:id])

    target_user_disable_flg = false
    users.each do |u|
      target_user_disable_flg = true if item.target_uid == u.id
    end

    return authentication_error(403) unless @gw_admin

    @items = DummyItem.new
    @items.users = Array.new
    @items.groups = Array.new

    item = @model.find_by(id: params[:id])
    target = item.target_uid
    @items.id = item.id

    items = System::ScheduleRole.where("target_uid = ?", [target]).order("user_id,id")
    @target_user_disable_flg = false
    items.each do |item|
      @disable_users.each do |u|
        if target == u.id
          @items.target = u.name + "（" + t("rumi.state.disabled") + "）"
          @target_user_disable_flg = true
        end
      end
      @users.each do |user|
        @items.target = user.name if target == user.id
        @items.users << user.name if item.user_id == user.id
      end
    end
    items = System::ScheduleRole.where("target_uid = ?", [target]).order("group_id,id")
    items.each do |item|
      @groups.each do |group|
        @items.groups << group.name if item.group_id == group.id
      end
    end

    if @items.target.blank?
      @items.target = "（" + t("rumi.config_settings.schedule_role.message.disable_user") + "）"
    end
  end

  def new
    init_params
    return authentication_error(403) unless @gw_admin

    @item = @model.new({})
  end

  def create
    init_params
    return authentication_error(403) unless @gw_admin

    @item = @model.new()
    target = params[:item][:uid_raw]
    item = @model.where("target_uid = ?", [target]).order("group_id,id")

    if item.blank?
      groups = ::JsonParser.new.parse(params[:item][:group_json])
      groups.each do |group|
        @item = @model.new()
        @item.target_uid = target
        @item.group_id = group[1]
        @item.created_at ='now()'
        @item.updated_at = 'now()'
        @item.save
      end
      users = ::JsonParser.new.parse(params[:item][:user_json])
      users.each do |user|
        @item = @model.new()
        @item.target_uid = target
        @item.user_id = user[1]
        @item.created_at ='now()'
        @item.updated_at = 'now()'
        @item.save
      end
      _create @item, :notice => t("rumi.message.notice.create")
    else
      @item.target_uid = target
      @item.errors.add :target_uid, t("rumi.error.registered")
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    init_params
    return authentication_error(403) unless @gw_admin

    @item = @model.find_by(id: params[:id])
    target = @item.target_uid
    users = Array.new
    groups = Array.new

    items = System::ScheduleRole.where("target_uid = ?", [target]).order("user_id,id")
    items.each do |item|
      @users.each do |user|
        users << ["", user.id, user.name] if item.user_id == user.id
      end
    end
    items = System::ScheduleRole.where("target_uid = ?", [target]).order("group_id,id")
    items.each do |item|
      @groups.each do |group|
        groups << ["", group.id, group.name] if item.group_id == group.id
      end
    end
    @user_json = users.to_json
    @group_json =groups.to_json
  end

  def update
    init_params
    return authentication_error(403) unless @gw_admin

    @item = @model.new()
    target = params[:item][:uid_raw]
    _item = @model.where("target_uid = ?", [target]).order("group_id,id")
    item = @model.find_by(id: params[:id])

    if _item.blank? || target.to_s == item.target_uid.to_s
      @model.where("target_uid = #{item.target_uid}").destroy_all

      groups = ::JsonParser.new.parse(params[:item][:group_json])
      groups.each do |group|
        @item = @model.new()
        @item.target_uid = params[:item][:uid_raw]
        @item.group_id = group[1]
        @item.created_at ='now()'
        @item.updated_at = 'now()'
        @item.save
      end

      users = ::JsonParser.new.parse(params[:item][:user_json])
      users.each do |user|
        @item = @model.new()
        @item.target_uid = params[:item][:uid_raw]
        @item.user_id = user[1]
        @item.created_at ='now()'
        @item.updated_at = 'now()'
        @item.save
      end
      _create @item, :notice => t("rumi.message.notice.update")
    else
      @item.target_uid = target
      @item.errors.add :target_uid, t("rumi.error.registered")
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    init_params
    return authentication_error(403) unless @gw_admin

    item = @model.find_by(id: params[:id])
    @model.where("target_uid = #{item.target_uid}").destroy_all
    _update item, :notice => t("rumi.message.notice.delete")
  end

  class DummyItem
    attr_accessor  :id, :target, :users, :groups;
  end

  class DummyItem2
    attr_accessor  :id, :name;
  end
end

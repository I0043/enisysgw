# encoding: utf-8
class System::Admin::CustomGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  before_action :set_groups_user, only: [:new, :create, :edit, :update]

  def initialize_scaffold
    @action = params[:action]
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::CustomGroup.where(id: id).first
    if params[:c1].present? && params[:c1] == "1"
      Page.title = t("rumi.custom_group.name_admin")
      @piece_head_title = t("rumi.custom_group.name_admin")
    else
      Page.title = t("rumi.custom_group.name")
      @piece_head_title = t("rumi.custom_group.name")
    end
    @side = "setting"
    
    created = System::CustomGroup.where(owner_uid: Core.user.id)
    @create_flg = created.size < Enisys::Config.application["system.custom_group"] ? true : false
  end

  # === 初期値のグループ、ユーザー情報
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def set_groups_user
    # グループ
    @selected_parent_group_id_to_group = Core.user_group.id

    # ユーザー
    @selected_parent_group_id_to_user = Core.user_group.id
    @selectable_affiliated_users = System::UsersGroup.affiliated_users_to_select_option(@selected_parent_group_id_to_user)
  end

  def init_index
    if @gw_admin && params[:c1].present? && params[:c1] == "1"
      cgids = System::CustomGroupRole.all
    else
      groups = System::UsersGroup.where(user_id: Core.user.id).map(&:group_id)
      class_id = System::CustomGroupRole.arel_table[:class_id]
      group_id = System::CustomGroupRole.arel_table[:group_id]
      user_id = System::CustomGroupRole.arel_table[:user_id]
      cgids = System::CustomGroupRole.select(:custom_group_id)
                                     .where((class_id.eq(2).and(group_id.in(groups))).or((class_id.eq(1).and(user_id.eq(Core.user.id)))))
                                     .where(priv_name: "admin")
    end
    id = System::CustomGroup.arel_table[:id]
    cgid = cgids.map(&:custom_group_id) if cgids.present?
    owner_uid = System::CustomGroup.arel_table[:owner_uid]
    if params[:keyword].present? && params[:reset].blank?
      @keyword = params[:keyword]
      items = System::CustomGroup.where((owner_uid.eq(Core.user.id).or(id.in(cgid))))
                                 .where("name like ? ", '%' + @keyword + '%')
    else
      items = System::CustomGroup.where((owner_uid.eq(Core.user.id).or(id.in(cgid))))
    end
    @items = items.order("owner_uid = #{Core.user.id} desc").order(:sort_prefix, :sort_no)
                  .page(params[:page])
  end

  def index
    init_index
    _index @items
  end

  def show
    return http_error(404)
  end

  def new
    @item = System::CustomGroup.new({
        :state        =>  'enabled',
    })
    @users = []

    base_users_json = []
    base_users_json << Core.user.to_json_option if @selectable_affiliated_users.map(&:id).include?(Core.user.id)
    base_users_json = base_users_json.to_json

    @admin_users_json = base_users_json
    @edit_users_json = base_users_json
    @read_users_json = base_users_json
  end

  def create
    @item = System::CustomGroup.new
    if @item.save_with_rels params, :create
      if @gw_admin && params[:c1].present? && params[:c1] == "1"
        redirect_to system_custom_groups_path(c1: 1), notice: t("rumi.message.notice.create")
      else
        redirect_to system_custom_groups_path, notice: t("rumi.message.notice.create")
      end
    else
      users = System::CustomGroup.get_error_users(params)
      @users_json = users.to_json
      @users = ::JsonParser.new.parse(@users_json)
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def get_users
    @users = ::JsonParser.new.parse(params[:item]['schedule_users_json'])
    @users.each_with_index {|user, i|
      @users[i][3] = params["title_#{user[1]}"]
      @users[i][4] = params["icon_#{user[1]}"]
      @users[i][5] = params["sort_no_#{user[1]}"]
    }
    respond_to do |format|
      format.xml { render :layout => false}
    end
  end

  def edit
    @item = System::CustomGroup.find_by(id: params[:id])
    init_edit(:edit)
  end

  def init_edit(mode)
    users = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'admin' && custom_group.class_id == 1 && !custom_group.user.blank?
        users.push [1, custom_group.user.id, custom_group.user.display_name]
      end
    end
    @admin_users_json = users.to_json

    groups = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'admin' && custom_group.class_id == 2 && !custom_group.group.blank?
        groups.push [2, custom_group.group.id, custom_group.group.ou_name]
      end
    end
    @admin_groups_json = groups.to_json

    users = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'edit' && custom_group.class_id == 1 && !custom_group.user.blank?
        users.push [1, custom_group.user.id, custom_group.user.display_name]
      end
    end
    @edit_users_json = users.to_json

    groups = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'edit' && custom_group.class_id == 2 && !custom_group.group.blank?
        groups.push [2, custom_group.group.id, custom_group.group.ou_name]
      end
    end
    @edit_roles_json = groups.to_json

    groups = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'read' && custom_group.class_id == 2 && !custom_group.group.blank?
        if custom_group.group_id == 0
          groups.push [2, 0, t("rumi.select.no_limit")]
        else
          groups.push [2, custom_group.group.id, custom_group.group.ou_name]
        end
      end
    end
    @roles_json = groups.to_json

    users = []
    @item.custom_group_role.each do |custom_group|
      if custom_group.priv_name == 'read' && custom_group.class_id == 1 && !custom_group.user.blank?
        users.push [1, custom_group.user.id, custom_group.user.display_name]
      end
    end
    @read_users_json = users.to_json

    if mode == :edit
      users = []
      @item.user_custom_group.each do |user|
        next if user.user.blank?
        users.push [1, user.user.id, user.user.display_name_only , user.title, user.icon, user.sort_no]
      end
      users = users.sort{|a,b|
        a[5] <=> b[5]
      }
      @users_json = users.to_json
      @users = ::JsonParser.new.parse(@users_json)
    else
      # エラー発生時、ユーザーの情報を保持する
      users = System::CustomGroup.get_error_users(params)
      @users_json = users.to_json
      @users = ::JsonParser.new.parse(@users_json)
    end
  end

  def edit_users

  end

  def update
    @item = System::CustomGroup.find(params[:id])
    if @item.save_with_rels params, :update
      if @gw_admin && params[:c1].present? && params[:c1] == "1"
        redirect_to system_custom_groups_path(c1: 1), notice: t("rumi.message.notice.update")
      else
        redirect_to system_custom_groups_path, notice: t("rumi.message.notice.update")
      end
    else
      init_edit(:update)
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def sort_update
    @item = System::CustomGroup.new
    unless params[:item].blank?
      params[:item].each{|key,value|
        if /^[0-9]+$/ =~ value
        else
          @item.errors.add :sort_no, t("rumi.error.number")
          break
        end
      }
    end

    if @item.errors.size == 0
      unless params[:item].blank?
       params[:item].each{|key,value|
         cgid = key.slice(8, key.length - 7 )
         item = System::CustomGroup.find_by(id: cgid)
         item.sort_no = value
         item.save
       }
     end
      if @gw_admin && params[:c1].present? && params[:c1] == "1"
        redirect_to system_custom_groups_path(c1: 1), notice: t("rumi.custom_group.message.sort_update_success")
      else
        redirect_to system_custom_groups_path, notice: t("rumi.custom_group.message.sort_update_success")
      end
   else
      init_index
      respond_to do |format|
        format.html { render :action => "index" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
   end
  end


  def destroy
    @item = System::CustomGroup.find(params[:id])
    if @item.destroy
      if @gw_admin && params[:c1].present? && params[:c1] == "1"
        redirect_to system_custom_groups_path(c1: 1), notice: t("rumi.message.notice.delete")
      else
        redirect_to system_custom_groups_path, notice: t("rumi.message.notice.delete")
      end

    else
      respond_to do |format|
        format.html { render :action => "index" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end
end

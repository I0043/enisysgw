# encoding: utf-8
class Gw::Admin::SmartSchedulesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::RumiHelper
  include RumiHelper
  layout "admin/template/smart_schedule"

  before_action :set_groups_user, only: [:new, :create, :edit, :update, :quote]

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "スケジュール"
  end

  # === 初期値のグループ、ユーザー情報
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def set_groups_user
    @selected_user = System::User.where(id: params[:uid]).first || Core.user
    @selected_group = @selected_user.enable_user_groups.first.group

    # 参加者
    @selected_parent_group_id_to_user = @selected_group.id
    @selectable_affiliated_users = System::UsersGroup.affiliated_users_to_select_option(@selected_parent_group_id_to_user, {without_level_no_2_organization: true, without_schedule_authority_user: true})

    # 公開所属
    @selected_parent_group_id_to_public = @selected_group.parent_id
    @selectable_child_groups = System::Group.child_groups_to_select_option(@selected_parent_group_id_to_public)
  end

  def init_params
    @title = 'スケジュール'
    @piece_head_title = 'スケジュール'
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)

    @users = Gw::Model::Schedule.get_users(params)
    @user   = @users[0]

    if @user.blank?
      @uid = nz(params[:uid], Core.user.id).to_i
      @uids = [@uid]
    else
      @uid    = @user.id
      @uids = @users.collect {|x| x.id}
    end
    @gid = nz(params[:gid], @user.groups[0].id).to_i rescue Core.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {is_default: 1, first: 1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @first_custom_group = System::CustomGroup.get_my_view( {sort_prefix: Core.user.code,first: 1})
    @ucode = Core.user.code
    @gcode = Core.user_group.code

    @state_user_or_group = params[:cgid].blank? ? ( params[:gid].blank? ? :user : :group ) : :custom_group
    @sp_mode = :schedule

    @group_selected = ( params[:cgid].blank? ? '' : 'custom_group_'+params[:cgid] )

    a_qs = []
    a_qs.push "uid=#{params[:uid]}" unless params[:uid].nil?
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @up_schedules = nz(Gw::Model::UserProperty.get('schedules'.singularize), {})

    @schedule_settings = Gw::Model::Schedule.get_settings 'schedules', {}

    @topdate = nz(params[:topdate]||Time.now.strftime('%Y%m%d'))
    @dis = nz(params[:dis],'week')


    @show_flg = true

    @params_set = Gw::Schedule.params_set(params.dup)
    @ref = Gw::Schedule.get_ref(params.dup)
    @link_params = Gw.a_to_qs(["gid=#{params[:gid]}", "uid=#{nz(params[:uid], Core.user.id)}", "cgid=#{params[:cgid]}"],{:no_entity=>true})

    @ie = Gw.ie?(request)
    @hedder2lnk = 1
    @link_format = "%Y%m%d"

    @type = Gw::PropType.select("id,name").where(state: "public").order(:sort_no, :id)
    @group = Gw::PropGroup.where(state: "public", parent_id: 1).where("id > ?", "1").order(:sort_no)
    @child = Gw::PropGroup.where(state: "public").where("parent_id > ?", "1").order(:sort_no)
    @prop_types=Array.new
    if !@type.blank?
      @type.each do | type|
        dummy = DummyItem.new
        dummy.id = "type_" + type.id.to_s
        dummy.name = type.name
        @prop_types << dummy
      end
    end

    if !@group.blank?
      dummy = DummyItem.new
      dummy.id = "-"
      dummy.name = "-----------------"
      @prop_types << dummy
      @group.each do | group|
        dummy = DummyItem.new
        dummy.id = "group_" + group.id.to_s
        dummy.name = "+" + group.name
        @prop_types << dummy
        @child.each do |child|
          if child.parent_id == group.id
            dummy = DummyItem.new
            dummy.id = "group_" + child.id.to_s
            dummy.name = "+-" + child.name
            @prop_types << dummy
          end
        end
      end
    end

    @target = schedule_authority_user
    @auth_flg = true
    get_smart_header_menus
  end

  def schedule_authority_user
    target = System::ScheduleRole.get_target_uids(Core.user.id)

    return target
  end

  def index
    init_params
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6

    @view = "week"

    if @users.length > 0
      @show_flg = true
    else
      @show_flg = false
    end

    _schedule_data
  end

  def new
    init_params

    is_public = Enisys::Config.application["schedule.is_public"].between?(1, 3) ? Enisys::Config.application["schedule.is_public"] : 1
    @item = Gw::Schedule.new({:is_public=>is_public})
    @system_role_classes = Gw.yaml_to_array_for_select('system_role_classes')
    @js += %w(/_common/modules/ips/ips.js)
    @css += %w(/_common/modules/ips/ips.css)
    if params[:prop_id].present?
      @_props = Array.new
      @_prop = Gw::PropOther.find_by(id: params[:prop_id])
      _get_prop_json_array
      @props_json = @_props.to_json
    end

    # 施設予約ではない、かつユーザーが参加者の選択済みに表示可能な場合、初期値として表示する
    if params[:s_genre] != "other" && @selectable_affiliated_users.map(&:id).include?(@selected_user.id)
      @users_json = ([@selected_user.to_json_option]).to_json
    end

    # 公開所属の初期値
    public_groups = []
    public_groups << @selected_group.to_json_option if @selectable_child_groups.map(&:id).include?(@selected_group.id)
    @public_groups_json = public_groups.to_json
  end

  def edit
    init_params

    @item = Gw::Schedule.where(id: params[:id]).first

    # 表示権限
    public_auth = @item.is_public_auth?(@gw_admin)
    return authentication_error(403) unless public_auth

    auth_level = @item.get_edit_delete_level(auth = {is_gw_admin: @gw_admin})

    return authentication_error(403) if auth_level[:edit_level] != 1
    users = []
    @item.schedule_users.each do |user|
      _name = ''
      if user.class_id == 1
        _name = user.user.display_name if !user.user.blank? && user.user.state == 'enabled'
      else
        group = System::Group.where(id: user.uid).first
        _name = group.name if !group.blank? && group.state == 'enabled'
      end
      unless _name.blank?
        name = Gw.trim(_name)
        users.push [user.class_id, user.uid, name]
      end
    end

    public_groups = Array.new
    @item.public_roles.each do |public_role|
      name = Gw.trim(public_role.class_id == 2 ? public_role.group.name :
          public_role.user.name)
      public_groups.push ["", public_role.uid, name]
    end

    @_props = Array.new
    @props_items = @item.schedule_props
    @props_items.each do |props_item|
      @_prop = props_item.prop
      @_props.push ["other", @_prop.id, "#{@_prop.name}"]
    end

    @users_json = users.to_json
    @props_json = @_props.to_json
    @public_groups_json = public_groups.to_json
  end

  def create
    init_params

    _params = reject_no_necessary_params params
    @item = Gw::Schedule.new()
    if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(@item, _params, :create)
      # 新着情報(新規作成時)を作成
      @item.build_created_remind

      flash[:notice] = I18n.t("rumi.schedule.message.success.action.create")
      redirect_url = "/gw/smart_schedules/#{@item.id}/show_one?m=new"
      redirect_to redirect_url
    else
      respond_to do |format|
        format.html { render action: "new" }
        format.xml  { render xml: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    init_params

    _params = reject_no_necessary_params params
    @item = Gw::Schedule.where(id: params[:id]).first
    _params = reject_no_necessary_params params

    if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(@item, _params, :update)
      # 新着情報(更新時)を作成
      # repeat_mode 1: 単体編集, 2: 繰り返し編集
      if params[:init][:repeat_mode].to_i == 2
        @item.repeat.first_day_schedule.build_updated_remind(true)
        flash[:notice] = I18n.t("rumi.schedule.message.success.action.update_repeat")
      else
        @item.build_updated_remind
        flash[:notice] = I18n.t("rumi.schedule.message.success.action.update")
      end

      redirect_url = "/gw/smart_schedules/#{@item.id}/show_one?m=edit"

      redirect_to redirect_url
    else
      respond_to do |format|
        format.html { render action: "edit" }
        format.xml  { render xml: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_day
    init_params
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day

    @view = "day"

    if @users.length > 0
      @show_flg = true
    else
      @show_flg = false
    end

    _schedule_data
    _schedule_day_data
    _schedule_user_data
  end

  def _schedule_data
    if @gw_admin || params[:cgid].blank? ||
        ( params[:cgid].present? && System::CustomGroupRole.new.editable?( params[:cgid], Core.user_group.id, Core.user.id ) )
      @edit = true
    else
      @edit = false
    end

    @schedules = Gw::Schedule.find_for_show_schedule(@uids,
      @calendar_first_day, @calendar_end_day,Core.user.id)

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)

  end

  def _schedule_day_data
    @calendar_first_time = 8
    @calendar_end_time = 19
    @schedules.each do |schedule|
      @calendar_first_time = 0 if schedule.st_at.to_date < @st_date
      @calendar_first_time = schedule.st_at.hour if schedule.st_at.to_date == @st_date && schedule.st_at.hour < @calendar_first_time
      @calendar_end_time = 23 if schedule.ed_at.to_date > @st_date
      @calendar_end_time = schedule.ed_at.hour if schedule.ed_at.to_date == @st_date && schedule.ed_at.hour > @calendar_end_time
    end

    @calendar_space_time = (@calendar_first_time..@calendar_end_time) # 表示する予定表の「最初の時刻」と「最後の時刻」の範囲

    @col = ((@calendar_space_time.last - @calendar_space_time.first) * 2) + 2

    @header_each ||= @schedule_settings[:header_each] rescue 5
    @header_each = nz(@header_each, 5).to_i
  end

  def _schedule_user_data
    @user_schedules = Hash::new
    @users.each do |user|
      key = "user_#{user.id}"
      @user_schedules[key] = Hash::new
      @user_schedules[key][:schedules] = Array.new
      @user_schedules[key][:allday_flg] = false
      @user_schedules[key][:allday_cnt] = 0

      @schedules.each do |schedule|
        participant = false
        schedule.schedule_users.each do |schedule_user|
          break if participant
          participant = schedule_user.uid == user.id
        end
        if participant
          @user_schedules[key][:schedules] << schedule
          if schedule.allday == 1 || schedule.allday == 2
            @user_schedules[key][:allday_flg] = true
            @user_schedules[key][:allday_cnt] += 1
          end
        end
      end

      @user_schedules[key][:schedule_len] = @user_schedules[key][:schedules].length

      if @user_schedules[key][:schedule_len] == 0
        @user_schedules[key][:trc] = "scheduleTableBody"
        @user_schedules[key][:row] = 1
      else
        if @user_schedules[key][:allday_flg] == true
          @user_schedules[key][:trc] = "alldayLine"
          @user_schedules[key][:row] = (@user_schedules[key][:schedule_len] * 2) - ((@user_schedules[key][:allday_cnt] * 2) - 1)
        else
          @user_schedules[key][:trc] = "scheduleTableBody categoryBorder"
          @user_schedules[key][:row] = @user_schedules[key][:schedule_len] * 2
        end
      end
    end
  end

  def _get_prop_json_array
    # セレクトボックス施設の中身用の配列を作成
    gid = @_prop.gid
    if gid.present?
      group = System::Group.find_by(id: gid)
      gname = "(#{System::Group.find_by(id: gid).name.to_s})" if group.present?
    else
      gname = ""
    end
    @_props.push ["other", @_prop.id, "#{@_prop.name}"]
  end

  # 削除された場合の処理メソッド（論理削除に変更）
  def delete_schedule
    init_params
    schedule_role(params[:id])

    @auth_flg = true
    @auth_flg = false if !@schedule_edit_flg

    @item = Gw::Schedule.where(id: params[:id]).first
    st = @item.st_at.strftime("%Y%m%d")

    redirect_url = "/gw/smart_schedules"

    ret = false
    ret = Gw::Schedule.save_updater_with_states(@item) if @gw_admin || @schedule_edit_flg

    if ret
      # 新着情報(論理削除時)を作成
      @item.build_deleted_remind

      flash[:notice] = I18n.t("rumi.schedule.message.success.action.delete")
      redirect_to redirect_url
    else
      respond_to do |format|
        format.html { render action: "show_one" }
        format.xml  { render xml: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # 繰返し削除された場合の処理メソッド（論理削除に変更）
  def delete_schedule_repeat
    init_params
    @item = Gw::Schedule.where(id: params[:id]).first
    st = @item.st_at.strftime("%Y%m%d")

    redirect_url = "/gw/smart_schedules"

    ret = false
    schedule_repeat_id = @item.schedule_repeat_id
    repeat_items = Gw::Schedule.where(schedule_repeat_id: schedule_repeat_id)
    @auth_flg = true
    repeat_items.each do |repeat_item|
      break if !@auth_flg
      if @auth_flg
        schedule_role(repeat_item.id)
        @auth_flg = false if !@schedule_edit_flg
      end
    end

    if @auth_flg
      repeat_items.each do |repeat_item|
        ret = Gw::Schedule.save_updater_with_states(repeat_item)
      end
    end
    if ret
      # 新着情報(論理削除時)を作成
      @item.reload.build_deleted_remind(true)

      flash[:notice] = I18n.t("rumi.schedule.message.success.action.delete_repeat")
      redirect_to redirect_url
    else
      @item = Gw::Schedule.where(id: params[:id]).first
      @auth_level = @item.get_edit_delete_level({is_gw_admin: @gw_admin})
      schedule_role(params[:id])

      @prop_edit = true
      @use_prop = false
      if @item.schedule_props.present?
        @use_prop = true
        @item.schedule_props.each do |schedule_prop|
          break if @prop_edit == false
          prop = schedule_prop.prop
          if @prop_edit == true && prop.present?
            @prop_edit = Gw::ScheduleProp.is_prop_edit?(prop.id, {prop: prop, is_gw_admin: @gw_admin})
          end
        end
      end
      respond_to do |format|
        format.html { render action: "show_one" }
        format.xml  { render xml: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def schedule_role(schedule_id = nil)
    #スケジュール権限判定
    @schedule_edit_flg = false
    _user = System::User.without_disable

    target_user = System::ScheduleRole.get_target_uids_schedule_user(Core.user.id, schedule_id)
    @schedule_edit_flg = target_user.blank?

    #権限対象者ユーザー名取得
    if @schedule_edit_flg == false
      @target_user = ''
      cnt = 0
      target_user.each do |t_user|
        _user.each do |user|
          if user.id == t_user.target_uid
            @target_user += user.name if cnt == 0
            @target_user += ", " + user.name if cnt == 1
            cnt = 1
          end
        end
      end
    end
  end

  def search_group
    @groups=Array.new

    options = {}
    custom_glist = System::CustomGroup.get_my_view( { priv: options[:priv] } )
    custom_glist.each {|x|
      prefix = (x.sort_prefix == '' ? '' : '個）')

      dummy = DummyItem.new
      dummy.id = 'cgroup_'+x.id.to_s
      dummy.name = prefix + x.name
      @groups << dummy
    }

    glist = System::Group.select("id, name").where(state: "enabled", level_no: 3)

    glist.each do |g|
      dummy = DummyItem.new
      dummy.id = 'group_'+g.id.to_s
      dummy.name = g.name
      @groups << dummy
    end
  end

  def search_user
    group = params[:group].split("_")
    if group[0] == "cgroup"
      @_users = System::UsersCustomGroup.where(custom_group_id: group[1])
    end
    if group[0] == "group"
      @_users = System::UsersGroup.where(group_id: group[1])
    end
    @users = Array.new
    @_users.each do |u|
      user = System::User.select("id, name").where(id: u.user_id, state: "enabled").first
      if user.present?
        dummy = DummyItem.new
        dummy.id = user.id.to_s
        dummy.name = user.name
        @users << dummy
      end
    end
  end

  def show_one
    init_params
    @item = Gw::Schedule.find_by(id: params[:id])

    @repeated = @item.repeated?

    @public_show = Gw::Schedule.is_public_show(@item.is_public)

    @prop_edit = true
    @use_prop = false
    if @item.schedule_props.present?
      @use_prop = true

      @item.schedule_props.each do |schedule_prop|
        break if @prop_edit == false
        prop = schedule_prop.prop
        if @prop_edit == true && prop.present?
          @prop_edit = Gw::ScheduleProp.is_prop_edit?(prop.id, {prop: prop, is_gw_admin: @gw_admin})
        end
      end
      if @gw_admin
        @prop_edit = @gw_admin
      end
    end
  end

  # === 既読にするボタン押下時の処理メソッド
  def finish
    init_params
    @item = Gw::Schedule.where(id: params[:id]).first
    @item.seen_remind(Core.user.id)

    flash[:notice] = I18n.t("rumi.schedule.message.success.action.already")
    redirect_url = "/gw/smart_schedules/#{@item.id}/show_one?m=finish"
    redirect_to redirect_url
  end

  private
  def reject_no_necessary_params(params_i)
    params_o = params_i.dup
    params_o[:item].reject!{|k,v| /^(owner_udisplayname)$/ =~ k}

    case params_o[:init][:repeat_mode]
    when "1"
      params_o[:item].reject!{|k,v| /^(repeat_.+)$/ =~ k}
    when "2"
      params_o[:item].delete :st_at
      params_o[:item].delete :ed_at
      params_o[:item][:repeat_weekday_ids] = Gw.checkbox_to_string(params_o[:item][:repeat_weekday_ids])
      params_o[:item][:allday] = params_o[:item][:repeat_allday]
      params_o[:item].delete :repeat_allday
    else
      raise Gw::ApplicationError, "指定がおかしいです(repeat_mode=#{params_o[:init][:repeat_mode]})"
    end

    params_o[:item].reject!{|k,v| /\(\di\)$/ =~ k}
    params_o
  end

  class DummyItem
    attr_accessor  :id, :name
  end
end

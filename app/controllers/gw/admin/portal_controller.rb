# encoding: utf-8
class Gw::Admin::PortalController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = I18n.t("rumi.top_page.name")
    @side = "portal"
  end

  def index
    session[:request_fullpath] = request.fullpath
    if logged_in?
      Core.user       = current_user
      Core.user_group = current_user.enable_user_groups.first.group
      # メッセージ
      @admin_message_items  = Gw::AdminMessage.where(state: 1)
                                .order('state ASC , sort_no ASC , updated_at DESC')
                                .limit(2)
      # スケジュール
      schedule_index
    else
      redirect_to _admin_login_path
    end
  end

  def schedule_index
    schedule_init_params
    @line_box = 1
    @st_date = Gw.date8_to_date params[:s_date]

    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6

    @view = "week"

    @show_flg = true
    @edit = true

    if @schedule_settings.present? && @schedule_settings.key?(:view_portal_schedule_display) &&
        nz(@schedule_settings[:view_portal_schedule_display], 1).to_i == 0
      @schedule_display = 0
    else
      _schedule_data
      @schedule_display = 1
    end
  end

  def schedule_init_params
    @title = t("rumi.schedule.table_title")
    @piece_head_title = t("rumi.schedule.name")
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)

    @users = [current_user]
    @user   = @users[0]

    if @user.blank?
      @uid = nz(params[:uid], current_user.id)
      @uids = [@uid]
    else
      @uid    = @user.id
      @uids = @users.collect {|x| x.id}
    end
    @gid = nz(params[:gid], @user.groups[0].id) rescue current_user.groups[0].id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end
    @sp_mode = :schedule

    a_qs = []
    a_qs.push "uid=#{@user.id}"
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @up_schedules = nz(Gw::Model::UserProperty.get('schedules'.singularize), {})

    @schedule_settings = Gw::Model::Schedule.get_settings 'schedules', {}

    @show_flg = true

    @params_set = Gw::Schedule.params_set(params.dup)
    @ref = Gw::Schedule.get_ref(params.dup)
    @link_params = Gw.a_to_qs(["gid=#{params[:gid]}", "uid=#{nz(params[:uid], current_user.id)}", "cgid=#{params[:cgid]}"],{:no_entity=>true})

    @ie = Gw.ie?(request)
    @hedder2lnk = 1
    @link_format = "%Y%m%d"
    @state_user_or_group = :user
  end

  def _schedule_data
    if @gw_admin || params[:cgid].blank? ||
        ( params[:cgid].present? && System::CustomGroupRole.editable?( params[:cgid], current_user.groups[0].id, current_user.id ) )
      @edit = true
    else
      @edit = false
    end
    @schedules = Gw::Schedule.find_for_show_schedule(@uids,
      @calendar_first_day, @calendar_end_day,current_user.id)

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)

  end
end

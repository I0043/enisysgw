# encoding: utf-8
class Gw::Admin::SmartSchedulePropsController < Gw::Admin::SmartSchedulesController
  include System::Controller::Scaffold
  include Gw::RumiHelper
  include RumiHelper
  layout "admin/template/smart_schedule_prop"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "施設予約"
  end

  def init_params
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)
    @css = %w(/_common/themes/gw/css/schedule.css)
    @schedule_settings = Gw::Model::Schedule.get_settings 'schedules', {}
    @s_other_admin_gid = nz(params[:s_other_admin_gid], "0").to_i

    get_smart_header_menus
  end

  def index
    init_params
    @prop_types = Gw::PropType.order(:sort_no).where(state: "public")
  end

  def list
    init_params
    @prop = Gw::PropOther.where(id: params[:id]).first
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6
    @view = "week"
    @prop_id = [params[:id]]

    if @gw_admin
      @prop_edit_id = @prop_id
      @prop_read_id = @prop_id
    else
      @prop_edit_id = Gw::PropOtherRole.where(prop_id: @prop_id, gid: search_ids, auth: 'edit').map(&:prop_id)
      @prop_read_id = Gw::PropOtherRole.where(prop_id: @prop_id, gid: search_ids, auth: 'read').map(&:prop_id)
    end

    _schedule_data
  end

  def select
    init_params
    @prop_type = Gw::PropType.where(id: params[:type_id]).first
    @props  =  Gw::Model::Schedule.get_props(params, @gw_admin, {:s_other_admin_gid=>@s_other_admin_gid, :type_id => params[:type_id]})
  end

  def show_day
    init_params
    @prop = Gw::PropOther.where(id: params[:prop_id]).first
    @props = Gw::PropOther.where(id: params[:prop_id]).first
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day
    @prop_id = [params[:prop_id]]

    _schedule_data
    _schedule_day_data
  end

  def _schedule_data
    if @prop_id.blank?
      @schedules = []
    else
      @schedules = Gw::Schedule.find_for_show(@prop_id, @calendar_first_day, @calendar_end_day, Core.user.id)
    end

    schedule_ids = @schedules.map(&:id)
    sql_result = []
    if schedule_ids.present?
      joined_schedule_ids = schedule_ids.join(',')
      user_id = Core.user.id
      sql =<<SQL
SELECT
  schedule_users.schedule_id,
  GROUP_CONCAT(DISTINCT system_users.name separator ', '),
  GROUP_CONCAT(DISTINCT prop_others.name separator ', ')
FROM
  #{gw_table_prefix}gw_schedule_users AS schedule_users
INNER JOIN
  system_users AS system_users ON schedule_users.uid = system_users.id
INNER JOIN
  gw_schedules AS schedules ON schedules.id = schedule_users.schedule_id
INNER JOIN
  gw_schedule_props AS schedule_props ON schedule_props.schedule_id = schedules.id
INNER JOIN
  gw_prop_others AS prop_others ON prop_others.id = schedule_props.prop_id
WHERE
  schedule_users.schedule_id IN (#{joined_schedule_ids})
GROUP BY
  schedule_users.schedule_id
SQL
      sql_result = Gw::Reminder.connection.execute(sql)
    end
    @schedule_data = {}
    sql_result.each {|schedule_id, user_names, prop_names|
      @schedule_data[schedule_id] = {user_names: user_names, prop_names: prop_names}
    }

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
  end

  def search_ids
    groups = Core.user.groups
    gids = []
    groups.each do |sg|
      gids << sg.id
      gids << sg.parent_id
    end
    gids << 0
    gids.uniq!
    return gids
  end
end

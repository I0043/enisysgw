# encoding: utf-8
class Gw::Admin::ScheduleUsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def show
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def new
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def create
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def edit
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def update
    raise Gw::SystemError, t("rumi.schedule.message.fraud")
  end

  def getajax
    return http_error(404) unless request.xhr?
    genre = params['s_genre']
    u = Core.user
    g = u.groups[0]
    case genre
    when nil
      nil
    when '_belong'
      cond = "state='enabled' and system_users_groups.group_id = #{g.id}"
      @item = System::User.where(cond).order('sort_no, code').joins('left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when 'login'
      @item = System::User.where("id=#{u.id}").collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when 'login_group'
      @item = System::Group.where("id=#{g.id}").collect{|x| [2, x.id, Gw.trim(x.name)]}
    when /^group_(\d+)$/
      cond = "state='enabled' and system_users_groups.group_id = #{$1}"
      @item = System::User.where(cond).order('sort_no, code').joins('left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when /^memo_group_(\d+)$/
      cond = "state='enabled' and system_users_groups.group_id = #{$1}"
      @item = System::User.where(cond).order('sort_no, code').joins('left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x|

      mobile_class = 'mobileOff'
      keitai_str = '&nbsp;&nbsp;&nbsp;&nbsp;'

     [1, x.id, "#{keitai_str if params[:firefox] == 'false'}" + Gw.trim(x.display_name), mobile_class]
        }
    when /^custom_group_(\d+)$/
      @item = []
      System::CustomGroup.find( "#{$1}" ).user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.collect{|x|
        @item.push [1, x.user.id, Gw.trim( x.user.display_name )] if !x.user.blank? && x.user.code != '000001_0' && x.user.state == 'enabled'
       }
    when /^child_group_(\d+)$/
      cond = "state='enabled' and system_users_groups.group_id = #{$1}"
      @item = System::User.where(cond).order('code').joins('left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    else
      raise Gw::SystemError, t("rumi.schedule.message.fraud")
    end
    respond_to do |format|
      format.json { render :json => @item }
    end
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

  def group_fields
    p_id = params[:p_id].to_s
    current_time = Time.now
    group_cond    = "state ='enabled'"
    group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
    group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    cond = "#{group_cond} and system_groups.parent_id = #{p_id}"
    groups = System::Group.where(cond).order("level_no, code")
    html_select = ""
    groups.each do |group|
      html_select << "<option value='#{group.id}'>#{group.name}</option>"
    end
    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end
end

class Gwboard::Admin::AjaxusersController < ApplicationController
  include System::Controller::Scaffold

  def getajax
    return http_error(404) unless request.xhr?
    prm = params
    gid = prm[:s_genre].to_s
    item = System::User.new
    @items =  System::User.select('system_users.*').where("system_users.state = 'enabled' and system_users_groups.group_id = ?", gid).joins('inner join system_users_groups on system_users.id = system_users_groups.user_id').order('system_users.sort_no, system_users.code').collect{|x| [x.code, x.id, "#{Gw.trim(x.name)}(#{x.code})"]}
    _show @items
  end

  def getajax_recognizer
    return http_error(404) unless request.xhr?
    prm = params
    gid = prm[:s_genre].to_s
    item = System::User.new
    item.and "sql", "NOT (system_users.id = #{params[:s_gr1g]})" unless params[:s_gr1g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr2g]})" unless params[:s_gr2g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr3g]})" unless params[:s_gr3g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr4g]})" unless params[:s_gr4g].blank?
    item.and "sql", "NOT (system_users.id = #{params[:s_gr5g]})" unless params[:s_gr5g].blank?
    @items = item.select('system_users.id,system_users.code,system_users.name').where("system_users.state = 'enabled' and system_users_groups.group_id = ?", gid).joins('inner join system_users_groups on system_users.id = system_users_groups.user_id').order('system_users.sort_no, system_users.code').collect{|x| [x.id, "#{Gw.trim(x.name)}(#{x.code})"]}
    _show @items
  end
end

# encoding: utf-8
class System::Admin::LdapGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.ldap.name")
    @piece_head_title = t("rumi.ldap.name")
    @side = "setting"
    @current_no = 2

    return error_auth unless Core.user.has_auth?(:manager)
    return render text: t("rumi.ldap.message.connect_fail"), layout: true unless Core.ldap.connection
    @role_admin = @admin = System::User.is_admin?
    return authentication_error(403) unless @admin == true

    if params[:parent] == '0'
      @parent  = nil
      @parents = []
    else
      @parent  = Core.ldap.group.find(params[:parent])
      @parents = @parent.parents
    end
  end
  
  def index
    if !@parent
      @groups = Core.ldap.group.children
      @users  = []
    else
      @groups = @parent.children
      @users  = @parent.users
    end
  end
end

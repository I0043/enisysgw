# encoding: utf-8
class Gw::Admin::ConfigSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.config_settings.base.header")
    @piece_head_title = t("rumi.config_settings.base.header")
    @side = "setting"
  end

  def init_params
    params[:limit] = nz(params[:limit], 30)
    doclibrary_admin
  end

  def index
    init_params
  end
  
  def doclibrary_admin
    @doclibrary_admin = @gw_admin
    unless @doclibrary_admin
      user_groups = System::UsersGroup.without_disable.where(user_id: Core.user.id)
      groups = System::Group.where(id: user_groups.map(&:group_id))
      group_ids = []
      groups.each do |group|
        group_ids << group.id
        group_ids << group.parent_id
      end
      adm = Doclibrary::Adm.where(user_id: 0, group_id: group_ids)
      @doclibrary_admin = true if adm.present?

      unless @doclibrary_admin
        adm = Doclibrary::Adm.where(user_id: Core.user.id)
        @doclibrary_admin = true if adm.present?
      end
    end
  end
end

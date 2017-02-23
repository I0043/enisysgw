# -*- encoding: utf-8 -*-
class Gwcircular::Admin::ItemdeletesController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize

  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.item_delete.gwcircular.name")
    @piece_head_title = t("rumi.item_delete.gwcircular.name")
    @side = "setting"

    return authentication_error(403) unless @gw_admin
  end

  def index
    @item = Gwcircular::Itemdelete.where(content_id: 0).first
  end

  def edit
    @item = Gwcircular::Itemdelete.where(content_id: 0).first
    return unless @item.blank?

    @item = Gwcircular::Itemdelete.create({
      :content_id => 0 ,
      :admin_code => Core.user.code ,
      :limit_date => '1.month'
    })
  end

  def update
    @item = Gwcircular::Itemdelete.where(content_id: 0).first
    return if @item.blank?
    @item.attributes = item_params
    location = gw_config_settings_path
    _update(@item, success_redirect_uri: location, notice: t("rumi.message.notice.delete_setting"))
  end

private

  def item_params
    params.require(:item)
          .permit(:limit_date)
  end
end

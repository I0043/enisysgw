class Gwcircular::Admin::AjaxgroupsController < ApplicationController
  include System::Controller::Scaffold

  def getajax
    return http_error(404) unless request.xhr?
    gid = ''
    gid = params[:s_genre] unless params[:s_genre].blank?
    if gid.blank?
      @item = []
    else
      @item = System::CustomGroup.get_user_select_ajax(gid)
    end
    _show @item
  end

end

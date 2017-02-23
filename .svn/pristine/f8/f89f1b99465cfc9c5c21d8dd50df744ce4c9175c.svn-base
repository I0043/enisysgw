# -*- encoding: utf-8 -*-
class Gwcircular::Admin::ExportFilesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title
    @item = Gwcircular::Doc.find_by(id: params[:gwcircular_id])
    return http_error(404) unless @item
    @piece_head_title = t('rumi.circular.name')
    @side = "gwcircular"
    return redirect_to("#{gwcircular_menus_path}#{s_cond}") if params[:reset]
  end

  def index
    f_name = "gwcircular_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
    f_name = params[:f_name] unless params[:f_name].blank?
    target_zip_file =Rails.root.join("tmp/gwcircular/#{f_name}")
    send_file target_zip_file if FileTest.exist?(target_zip_file)

    unless FileTest.exist?(target_zip_file)
      flash[:notice] = I18n.t('rumi.gwcircular.message.no_export_file')
      redirect_to :back
    end
  end

private
  def invalidtoken

  end
end

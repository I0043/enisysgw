# encoding: utf-8
class System::Admin::LoginImagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::Controller::Image
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.login_image.name")
    @piece_head_title = t("rumi.login_image.name")
    @side = "setting"

    return authentication_error(403) unless @gw_admin
  end

  def index

  end

  def image_upload
    item = params[:login_image]
    _login_image_create item
  end

private

  def login_image_params
    params.require(:login_image)
          .permit(:upload)
  end
end

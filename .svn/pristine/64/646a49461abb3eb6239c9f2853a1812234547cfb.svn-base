# encoding: utf-8
class Gw::Admin::PropTypesController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.prop_type.name")
    @piece_head_title = t("rumi.prop_type.name")
    @side = "setting"
    @sp_mode = :prop

    return authentication_error(403) unless @gw_admin
  end

  def index
    @items = Gw::PropType.where("state = ?", "public").order("sort_no")
    _index @items
  end

  def show
    @item = Gw::PropType.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    _show @item
  end

  def new
    @item = Gw::PropType.new
  end

  def create
    @item = Gw::PropType.new(item_params)
    @item.state = "public"
    _create @item, notice: t("rumi.message.notice.create")
  end

  def edit
    @item = Gw::PropType.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
  end

  def update
    @item = Gw::PropType.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    @item.attributes = item_params

    _update @item, success_redirect_uri: gw_prop_type_path(@item.id), notice: t("rumi.message.notice.update")
  end

  def destroy
    @item = Gw::PropType.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    @item.state = "delete"
    @item.deleted_at  = Time.now
    _update @item, notice: t("rumi.message.notice.delete")
  end

private
  def item_params
    params.require(:item)
          .permit(:name, :sort_no)
  end
end

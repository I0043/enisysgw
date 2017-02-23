# encoding: utf-8
class Gw::Admin::PropOtherLimitsController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.prop_other_limit.name")
    @piece_head_title = t("rumi.prop_other_limit.name")
    @side = "setting"
    @prop_types = Gw::PropType.where(state: "public")
                              .select("id, name")
                              .order("sort_no, id")
    return authentication_error(403) unless @gw_admin
  end

  def index
    @items = Gw::PropOtherLimit.where("state = 'enabled'").order("sort_no")
  end

  def show
    @item = Gw::PropOtherLimit.find(params[:id])
  end

  def new
    flash[:notice] = t("rumi.prop_other_limit.message.valid_new")
    redirect_to gw_prop_other_limits_path
    return
  end

  def create
    @item = Gw::PropOtherLimit.new.find(params[:id])
    @item.attributes = item_params

    _update @item, success_redirect_uri: gw_prop_other_limits_path, notice: t("rumi.message.notice.create")
  end

  def edit
    @item = Gw::PropOtherLimit.find(params[:id])
  end

  def update
    @item = Gw::PropOtherLimit.find(params[:id])
    @item.attributes = item_params

    _update @item, success_redirect_uri: gw_prop_other_limit_path(params[:id]), notice: t("rumi.message.notice.update")
  end

  def destroy
    @item = Gw::PropOtherLimit.find(params[:id])

    _destroy @item, success_redirect_uri: gw_prop_other_limits_path, notice: t("rumi.message.notice.delete")
  end

  def synchro
    items = Gw::PropOtherLimit.update_all("state = 'disabled'")
    groups = System::Group.where("state = 'enabled' and level_no = 3").order("sort_no")

    groups.each { |group|
      _model = Gw::PropOtherLimit.find_by_gid(group.id)
      if _model.blank?
        _model = Gw::PropOtherLimit.new
        _model.state = "enabled"
        _model.gid = group.id
        _model.sort_no = group.sort_no
        _model.limit = 100
      else
        _model.state = "enabled"
        _model.sort_no = group.sort_no
      end
      _model.save!
    }
    flash[:notice] = t("rumi.prop_other_limit.message.synchro_success")
    redirect_to gw_prop_other_limits_path
  end

private

  def item_params
    params.require(:item)
          .permit(:gid, :limit)
  end

end

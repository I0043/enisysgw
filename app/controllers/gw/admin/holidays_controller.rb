# encoding: utf-8
class Gw::Admin::HolidaysController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @category_id = nz(params[:category], 1).to_i rescue 1
    @hcs = Gw.yaml_to_array_for_select('gw_holiday_categories')
    @category_title = @hcs.rassoc(@category_id)[0]
    @piece_head_title = t("rumi.config_settings.scheduler.holiday.name")
    Page.title = t("rumi.config_settings.scheduler.holiday.name")
    @side = "setting"
  end

  def index
    return authentication_error(403) unless @gw_admin
    @items = Gw::Holiday.where("coalesce(title_category_id,1)=#{@category_id}")
                        .order(:st_at)
                        .paginate(page: params[:page]).limit(30)
  end

  def show
    return authentication_error(403) unless @gw_admin
    @item = Gw::Holiday.find_by(id: params[:id])
  end

  def new
    return authentication_error(403) unless @gw_admin
    @item = Gw::Holiday.new({})
  end

  def edit
    return authentication_error(403) unless @gw_admin
    @item = Gw::Holiday.find_by(id: params[:id])
  end

  def create
    return authentication_error(403) unless @gw_admin
    u = Core.user; g = u.groups[0]
    if params[:item].present?
      if params[:item]['st_at(1i)'].present?
        params[:item].reject!{|k,v| /\(\di\)$/ =~ k}
      end
    end
    params[:item][:st_at] = params[:item][:st_at] + " 00:00:00"
    @item = Gw::Holiday.new(item_params)
    @item.creator_uid = u.id
    @item.creator_ucode = u.code
    @item.creator_uname = u.name
    @item.creator_gid = g.id
    @item.creator_gcode = g.code
    @item.creator_gname = g.name
    @item.title_category_id = @category_id
    @item.is_public = 1
    @item.no_time_id = 1
    @item.ed_at = @item.st_at
    _create @item, :success_redirect_uri => "/gw/holidays?category=#{@category_id}", :notice => t("rumi.message.notice.create")
  end

  def update
    return authentication_error(403) unless @gw_admin
    @item = Gw::Holiday.find(params[:id])
    if params[:item].present?
      if params[:item]['st_at(1i)'].present?
        params[:item].reject!{|k,v| /\(\di\)$/ =~ k}
      end
    end
    params[:item][:st_at] = params[:item][:st_at] + " 00:00:00"

    @item.attributes = item_params.merge({
      :ed_at => params[:item][:st_at],
    })
    _update @item, :success_redirect_uri => "/gw/holidays?category=#{@category_id}", :notice => t("rumi.message.notice.update")
  end

  def destroy
    return authentication_error(403) unless @gw_admin
    @item = Gw::Holiday.find(params[:id])

    location = gw_holidays_path
    _destroy(@item,:success_redirect_uri=>location)
  end

private

  def item_params
    params.require(:item)
          .permit(:st_at, :title)
  end

end

# encoding: utf-8
class Gw::Admin::EditLinkPiecesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include GwHelper
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = I18n.t("rumi.config_settings.top_page.link_piece.name")
    @piece_head_title = t("rumi.config_settings.top_page.link_piece.name")
    @side = "setting"
  end

  def init_params
    params[:limit] = nz(params[:limit],30)
  end

  def index
    init_params
    return authentication_error(403) unless @gw_admin

    @items = Gw::EditLinkPiece.where(state: "enabled", level_no: 4)
                              .order(:sort_no)
                              .paginate(page: params[:page]).limit(params[:limit])
    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @gw_admin

    @item = Gw::EditLinkPiece.find_by(id: params[:id])
    return http_error(404) if @item.uid != nil
  end

  def new
    init_params
    return authentication_error(403) unless @gw_admin

    max_sort = Gw::EditLinkPiece.where(state: "enabled")
                                .order("sort_no DESC")
                                .first
    
    max_sort_no = max_sort.blank? ? 0 : max_sort.sort_no

    @item = Gw::EditLinkPiece.new
    @item.parent_id       = nil
    @item.level_no        = 4
    @item.state           = 'enabled'
    @item.published       = 'opened'
    @item.tab_keys        = 0
    @item.sort_no         = max_sort_no.to_i + 10
    @item.class_created   = 1
    @item.class_external  = 1
    @item.class_sso       = 1
  end

  def create
    init_params
    return authentication_error(403) unless @gw_admin
    @item = Gw::EditLinkPiece.new(item_params)
    return http_error(404) if @item.uid != nil

    _create @item, :success_redirect_uri => url_for(:action => :index)
  end

  def edit
    init_params
    return authentication_error(403) unless @gw_admin
    return http_error(404) if !@parent.blank? && @parent.uid != nil

    @item = Gw::EditLinkPiece.find_by(id: params[:id])
    return http_error(404) if @item.uid != nil
  end

  def update
    init_params
    @item = Gw::EditLinkPiece.find_by(id: params[:id])
    return http_error(404) if @item.uid != nil
    @item.attributes = item_params
    _update @item, :success_redirect_uri => url_for(:action => :index)
  end

  def destroy
    init_params
    return authentication_error(403) unless @gw_admin

    item = Gw::EditLinkPiece.find_by(id: params[:id])
    return http_error(404) if item.uid != nil
    item.published      = 'closed'
    item.state          = 'deleted'
    item.tab_keys       = nil
    item.sort_no        = nil
    item.deleted_at     = Time.now
    item.deleted_user   = Core.user.name
    item.deleted_group  = Core.user_group.name
    item.save(:validate => false)

    redirect_to url_for(:action => :index, :pid => @pid)
  end

  def updown
    init_params
    return authentication_error(403) unless @gw_admin
    return http_error(404) if !@parent.blank? && @parent.uid != nil

    item = Gw::EditLinkPiece.find_by(id: params[:id])
    return http_error(404) if item.uid != nil
    if item.blank?
      redirect_to url_for(:action => :index, :pid => @pid)
      return
    end

    updown = params[:order]

    case updown
    when 'up'
      cond  = "state!='deleted' and parent_id=#{@pid} and sort_no < #{item.sort_no} "
      order = " sort_no DESC "
      item_rep = Gw::EditLinkPiece.where(cond).order(order).first
      return http_error(404) if item_rep.uid != nil
      if item_rep.blank?
      else
        sort_work = item_rep.sort_no
        item_rep.sort_no = item.sort_no
        item.sort_no = sort_work
        item.save(:validate => false)
        item_rep.save(:validate => false)
      end
    when 'down'
      cond  = "state!='deleted' and parent_id=#{@pid} and sort_no > #{item.sort_no} "
      order = " sort_no ASC "
      item_rep = Gw::EditLinkPiece.where(cond).order(order).first
      return http_error(404) if item_rep.uid != nil
      if item_rep.blank?
      else
        sort_work = item_rep.sort_no
        item_rep.sort_no = item.sort_no
        item.sort_no = sort_work
        item.save(:validate => false)
        item_rep.save(:validate => false)
      end
    else
    end

    redirect_to url_for(:action => :index, :pid => @pid)
  end

  def swap
    init_params
    return authentication_error(403) unless @gw_admin
    return http_error(404) if !@parent.blank? && @parent.uid != nil

    item1 = Gw::EditLinkPiece.find(params[:id]) rescue nil
    item2 = Gw::EditLinkPiece.find(params[:sid]) rescue nil
    return http_error(404) if item1.blank? || item1.deleted? || item1.uid != nil
    return http_error(404) if item2.blank? || item2.deleted? || item2.uid != nil

    Gw::EditLinkPiece.swap(item1, item2)

    redirect_to url_for(:action => :index, :pid => @pid)
  end

private

  def item_params
    params.require(:item)
          .permit(:class_created, :parent_id, :level_no, :sort_no, :class_external, :class_sso, :published, :state,
                  :name, :tab_keys, :location, :link_url)
  end

end

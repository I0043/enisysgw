# encoding: utf-8
class Gw::Admin::PropGenreCommonController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::Controller::Image
  layout "admin/template/schedule"

  def initialize_scaffold
    @sp_mode = :prop
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def init_params
    @module = 'gw'
    @genre_prefix = 'prop'
    @index_order = "delete_state, reserved_state desc, coalesce(extra_flag,'other'), gid, coalesce(sort_no, 0), name"
    @cls = nz(Gw.trim(nz(params[:cls])).downcase, 'other')

    @group = Core.user_group
    @gid = @group.id
  end

  def index
    init_params
    item = @model.new
    item.page  params[:page], params[:limit]
    item.order @index_order unless @index_order.nil?
    cond = @cls == 'other' ? "coalesce(extra_flag, 'other') = 'other' and gid=#{@gid}" : "extra_flag='#{@cls}'"
    if @genre == 'other'
      cond += "	and delete_state = 0"
    end
    @items = item.where(cond)
  end

  def show
    init_params
    @item = @model.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @gw_admin
    @item = @model.new({})
  end

  def create
    init_params
    return authentication_error(403) unless @gw_admin
    par_item = params[:item]

    item = pre_save_proc(par_item)
    @item = @model.new(item)
    _create @item, success_redirect_uri: "#{@uri_base}?cls=#{@cls}", notice: t("rumi.message.notice.create")
  end

  def edit
    init_params
    @item = @model.find(params[:id])
    return authentication_error(403) unless @gw_admin
  end

  def update
    init_params
    return authentication_error(403) unless @gw_admin
    par_item = params[:item]
    @item = @model.find(params[:id])
    item = pre_save_proc(par_item)
    @item.attributes = item
    _update @item, :success_redirect_uri => "#{@uri_base}?cls=#{@cls}", notice: t("rumi.message.notice.update")
  end

  def destroy
    init_params
    @item = @model.find(params[:id])
    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
    return authentication_error(403) unless @gw_admin
    @item.delete_state = 1
    _update @item, :success_redirect_uri => "#{@uri_base}?cls=#{@cls}", notice: t("rumi.message.notice.delete")
  end

  def upload
    init_params
    return authentication_error(403) unless @gw_admin
    @item = @model.find(params[:id])
    @image_upload_qsa = ["cls=#{@cls}"]
  end

  def image_create
    init_params
    return authentication_error(403) unless @gw_admin
    @image_upload_qsa = ["cls=#{@cls}"]
    _image_create @model_image, 'gw', @genre, params, :genre_name_prefix=>'prop'
  end

  def image_destroy
    init_params
    if @genre == 'other' && !@gw_admin
      image = @model_image.find(params[:id])
      @prop_admin = Gw::PropOtherRole.is_admin?(image.parent_id)
    end
    return authentication_error(403) unless @gw_admin || @prop_other_admin
    @image_upload_qsa = ["cls=#{@cls}"]
    _prop_image_destroy @model_image, 'gw', @genre, params, :genre_name_prefix=>'prop'
  end

private
  def pre_save_proc(item)
    item[:extra_flag] = nz(item['sub']['extra_flag'], 'other')
    if @genre == 'other'
      item[:gid] = nz(item['sub']['gid'])
      item[:gname] = System::Group.where("id=#{item[:gid]}").first.name
      item = item.merge( :edit_state => 0 ) if item[:edit_state].blank?
    end
    item.delete 'sub'
    return item
  end

  def other_admin(item)
    if @genre != 'other'
      return true
    elsif @gid.to_i == item.gid.to_i
      return true
    else
      return false
    end
  end
end

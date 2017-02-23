# encoding: utf-8
class Gw::Admin::PropGroupsController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.prop_group.name")
    @piece_head_title = t("rumi.prop_group.name")
    @side = "setting"
    @sp_mode = :prop

    @genre = 'group'
    @model = Gw::PropGroup
    return authentication_error(403) unless @gw_admin
    if params[:id].blank?
      @parent = Gw::PropGroup.select("id,name")
                             .where(state: "public", parent_id: "1")
                             .order(:sort_no)
    else
      @parent = Gw::PropGroup.select("id,name")
                             .where(state: "public", parent_id: "1")
                             .where.not(id: params[:id])
                             .order(:sort_no)
    end
  end

  def index
    @group = Gw::PropGroup.where(state: "public", parent_id: 1)
                          .where("id > ?", "1")
                          .order(:sort_no)
    @child = Gw::PropGroup.where(state: "public")
                          .where("parent_id > ?", "1")
                          .order(:sort_no)

    @items = Array.new
    @group.each do |item|
      @d = DummyItem3.new
      @d.id, @d.name, @d.sort_no = item.id, item.name, item.sort_no
      parent = Gw::PropGroup.where(id: item.parent_id).first
      @d.parent_name = parent.present? ? parent.name : ""
      @items << @d

      @child.each do |child|
        if child.parent_id == item.id
          @d = DummyItem3.new
          @d.id, @d.name, @d.sort_no = child.id, "　　" + child.name, child.sort_no
          parent = Gw::PropGroup.where(id: child.parent_id).first
          @d.parent_name = parent.present? ? parent.name : ""
          @items << @d
        end
      end
    end
  end

  def show
    @item = Gw::PropGroup.where(id: params[:id]).first
    parent_id = @item.present? ? @item.parent_id : 1
    @parent = Gw::PropGroup.where(id: parent_id).first
      
    return http_error(404) if @item.blank? || @item.state == "delete"
    _show @item
  end

  def new
    @item = Gw::PropGroup.new
    @item.parent_id = 1
    @parent = Gw::PropGroup.select("id,name")
                           .where(state: "public", parent_id: "1")
                           .order(:sort_no)
  end

  def create
    @item = Gw::PropGroup.new(item_params)
    @item.state = "public"
    _create @item
  end

  def edit
    @item = Gw::PropGroup.find_by(id: params[:id])
    @parent = Gw::PropGroup.select("id,name")
                           .where(state: "public", parent_id: "1")
                           .where.not(id: params[:id])
                           .order(:sort_no)
    return http_error(404) if @item.blank? || @item.state == "delete"
  end

  def update
    @item = Gw::PropGroup.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"

    @childitems = Gw::PropGroup.where(state: "public", parent_id: params[:id])
                               .order(:sort_no)
    @item.attributes = item_params
    if @childitems.present?
      if @item.parent_id != 1
        @childitems.each do |child|
          child.parent_id = 1
          child.save
        end
      end
    end

    _update @item, success_redirect_uri: gw_prop_group_path(@item.id)
  end

  def destroy
    @item = Gw::PropGroup.find_by(id: params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"

    @item.state = "delete"
    @item.deleted_at  = Time.now
    @childitems = Gw::PropGroup.where(state: "public", parent_id: params[:id])
                               .order(:sort_no)
    if @childitems.blank?
    else
      @childitems.each do | child|
        child.state = "delete"
        child.deleted_at = Time.now
        child.save
      end
    end
    _update @item, :notice => t("rumi.message.notice.delete")
  end

  class DummyItem3
    attr_accessor  :id, :name, :parent_name, :sort_no
  end

private

  def item_params
    params.require(:item)
          .permit(:name, :parent_id, :sort_no)
  end
end
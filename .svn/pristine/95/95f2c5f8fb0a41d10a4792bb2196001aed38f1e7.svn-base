# encoding: utf-8
class Gw::Admin::PropGroupSettingsController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.prop_group_setting.name")
    @piece_head_title = t("rumi.prop_group_setting.name")
    @side = "setting"
    @sp_mode = :prop
    @genre = 'group'

    @group = Gw::PropGroup.where(state: "public", parent_id: 1)
                          .where("id > ?", 1)
                          .order(:sort_no)
    @prop_types = Gw::PropType.where(state: "public").select("id, name")

    return authentication_error(403) unless @gw_admin
  end

  def index
    @items = Array.new
    @group.each do |group|
      d = DummyItem3.new
      d.id, d.name = group.id, group.name
      
      settings = Gw::PropGroupSetting.where(prop_group_id: group.id)
      others = Gw::PropOther.where(id: settings.map(&:prop_other_id))
      d.setsubi = others.map(&:name).join("<br />").html_safe
      @items << d

      child = Gw::PropGroup.where(state: "public", parent_id: group.id)
      child.each do |child|
        d = DummyItem3.new
        d.id, d.name  = child.id, "　　"+child.name
        settings = Gw::PropGroupSetting.where(prop_group_id: child.id)
        others = Gw::PropOther.where(id: settings.map(&:prop_other_id))
        d.setsubi = others.map(&:name).join("<br />").html_safe
        @items << d
      end
    end
  end

  class DummyItem3
    attr_accessor  :id, :name, :setsubi, :sort_no
  end

  def init_params
  end

  def edit
    @item = Gw::PropGroup.find(params[:id])
    @def_prop = Gw::PropType.select("id").where(state: "public").order("id")
    id = 0
    @def_prop.each do |prop|
      id = prop.id if id == 0 || id > prop.id
    end
    params[:type_id] = id
    @_props = Array.new
    @props_items = Gw::PropGroupSetting.where(prop_group_id: params[:id])
                                       .order("prop_other_id")
    @props_items.each do |props_item|
      @_prop = Gw::PropOther.find(props_item.prop_other_id)
      if @_prop.delete_state == 0
        _get_prop_json_array
      end
    end
    @prop_group_settings_json = @_props.to_json
  end

  def _get_prop_json_array
    # セレクトボックス施設の中身用の配列を作成
    gid = @_prop.gid
    if gid.present?
      group = System::Group.find_by(id: gid)
      gname = "(#{System::Group.find_by(id: gid).name.to_s})" if group.present?
    else
      gname = ""
    end
    @_props.push ["other", @_prop.id, "#{gname}#{@_prop.name}"]
  end

  def create
    @item = Gw::PropGroupSetting.new(params[:item])
  end

  def update
    _params = params.dup
      @item = Gw::PropGroup.find(params[:id])
    _params = params.dup

    props = JsonParser.new.parse(params[:item][:prop_group_settings_json])
    prop_group_id = params[:id]
    Gw::PropGroupSetting.where("prop_group_id = #{prop_group_id}").destroy_all
    props.each_with_index{|prop, y|
      new_prop = Gw::PropGroupSetting.new()
      new_prop.prop_group_id = params[:id]
      new_prop.prop_other_id = prop[1]
      new_prop.created_at = 'now()'
      new_prop.updated_at = 'now()'
      new_prop.save
    }
    flash[:notice] = t("rumi.message.notice.update")
    redirect_url = "/gw/prop_group_settings"
    redirect_to redirect_url
  end

  def getajax
    return http_error(404) unless request.xhr?
    @item = Gw::PropGroupSetting.getajax params
    respond_to do |format|
      format.json { render :json => @item }
    end
  end
end

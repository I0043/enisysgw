# encoding: utf-8
class Gw::Admin::PropOthersController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  include Gw::RumiHelper
  layout "admin/template/portal"

  before_action :set_groups_user, only: [:new, :create, :edit, :update]

  def initialize_scaffold
    super
    @genre = 'other'
    @model = Gw::PropOther
    @model_image = Gw::PropOtherImage
    @uri_base = '/gw/prop_others'
    @item_name = t("rumi.prop_other.name")
    Page.title = t("rumi.prop_other.name")
    @piece_head_title = t("rumi.prop_other.name")
    @side = "setting"
    @show_one = false
    #現状の@prop_typesを施設グループも含めるようにする
    @prop_types = Gw::PropType.where(state: "public").select("id, name").order('sort_no, id')

    gids = []
    Core.user.groups.each do |group|
      gids << group.id
      gids << group.parent_id
    end
    @prop_admin = false
    if gids.present?
      gids.uniq!
      @search_gids = Gw.join([gids], ',')
      cond = " auth='admin' and gid in (#{@search_gids}) "
      auth_admin = Gw::PropOtherRole.where(cond)
      @prop_admin = true if auth_admin.present?
    end
  end

  # === 初期値のグループ、ユーザー情報
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def set_groups_user
    @parent_group_id = Core.user_group.parent_id
    @group_child_groups = System::Group.child_groups_to_select_option(@parent_group_id)
  end

  def get_index_items
    @s_admin_group = Gw::PropOtherRole.get_search_select("admin", @gw_admin)
  end

  def index
    init_params
    return authentication_error(403) unless @gw_admin || @prop_admin
    get_index_items

    @prop_types = select_prop_type
    @prop_types += select_prop_group_tree('partition')
    prop_type_types = Gw::PropType.where(state: "public").select("id, name").order('sort_no, id')

    if params[:s_type_id].present?
      @type_id = params[:s_type_id]
    else
      if prop_type_types.present?
        @type_id = @prop_types[0]
        match_type_id = @type_id[1].match(/^type_(\d+)$/)
        @default_type_id = match_type_id[1]
      end
    end

    ids = false
    types = false
    items = Gw::PropOther.where(delete_state: 0)
    if (params[:s_type_id]).present?
      if (match_result = params[:s_type_id].match(/^groups_(\d+)$/))
        s_type_id = match_result
        @group_set = Gw::PropGroupSetting.where(prop_group_id: [s_type_id[1].to_i]).select(:prop_other_id)
        ids = @group_set.blank? ? 0 : @group_set.map(&:prop_other_id)
      elsif (match_result = params[:s_type_id].match(/^type_(\d+)$/))
        s_type_id = match_result
        types = s_type_id[1].to_i
      else
        types = @default_type_id.to_i
      end
    else
      types = @default_type_id.to_i
    end

    @s_admin_gid = nz(params[:s_admin_gid], "0").to_i

    #　TODO limitの値のデフォルトを設定すること
    items = items.where(id: ids) if ids.present?
    items = items.where(type_id: types) if types.present?

    cond = ""
    if @s_admin_gid != 0 && @gw_admin
      s_other_admin_group = System::GroupHistory.find_by(id: @s_admin_gid)
      if s_other_admin_group.level_no == 2
        group_ids = System::GroupHistory.where(parent_id: @s_admin_gid).map(&:id)
        group_ids << @s_admin_gid

        search_group_ids = group_ids.join(',')
        cond += "(auth = 'admin' and  gw_prop_other_roles.gid in (#{search_group_ids}))"
      else
        cond += "(auth = 'admin' and  gw_prop_other_roles.gid = #{s_other_admin_group.id})"
      end
    elsif !@gw_admin
      if @search_gids.blank?
        cond += "auth = 'admin' and ((gw_prop_other_roles.gid = #{Site.user_group.id}) or (gw_prop_other_roles.gid = 0))" if !@gw_admin
      else
        cond += "auth = 'admin' and (gw_prop_other_roles.gid in (#{@search_gids}) or (gw_prop_other_roles.gid = 0))" if !@gw_admin
      end
    end

    @items = items.where(cond)
                  .order("sort_no, id")
                  .joins(:prop_other_roles)
                  .group("prop_id")
  end

  def new
    init_params
    return authentication_error(403) unless @gw_admin

    @item = @model.new({})
    @prop_types = Gw::PropType.where("state = ?", "public").select("id, name").order('sort_no, id')

    base_groups_json = []
    base_groups_json << Core.user_group.to_json_option if @group_child_groups.map(&:id).include?(Core.user_group.id)
    base_groups_json = base_groups_json.to_json

    @admin_json = base_groups_json
    @editors_json = base_groups_json
    @readers_json = []
  end

  def show
    init_params
    @item = @model.find(params[:id])

    if @item.delete_state == 1
      if @genre == 'other'
        return authentication_error(404) unless @gw_admin
      end
    end

    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
  end

  def create
    init_params
    return authentication_error(403) unless @gw_admin
    @item = @model.new()

    if @item.save_with_rels params, :create
      flash[:notice] = t("rumi.message.notice.create")
      redirect_to gw_prop_others_path(cls: @cls)
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    init_params
    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
    return authentication_error(403) unless @gw_admin || @is_other_admin
    @item = @model.find(params[:id])
    if @item.save_with_rels params, :update
      flash[:notice] = t("rumi.message.notice.update")
      redirect_to gw_prop_other_path(@item.id, cls: @cls)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    init_params
    @prop_types = Gw::PropType.where(state: "public").select("id, name").order('sort_no, id')
    @item = @model.find(params[:id])
    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
    return authentication_error(403) unless @gw_admin || @is_other_admin

    @admin_json = @item.admin(:select).to_json
    @editors_json = @item.editor(:select).to_json
    @readers_json = @item.reader(:select).to_json
  end

  class DummyItem
    attr_accessor  :id, :name
  end

  # === 施設マスタインポートメソッド
  #  本メソッドは施設マスタのCSVインポートを行うメソッドである。
  # ==== 引数
  #  無し
  # ==== 戻り値
  #  無し
  def import
    init_params
    return authentication_error(403) unless @gw_admin
    Page.title = t("rumi.prop_other.menu.import")
    @piece_head_title = t("rumi.prop_other.menu.import")
  end

  # === 施設マスタエクスポートメソッド
  #  本メソッドは施設マスタのCSVエクスポートを行うメソッドである。
  # ==== 引数
  #  無し
  # ==== 戻り値
  #  無し
  def export
    init_params
    return authentication_error(403) unless @gw_admin
    get_index_items
    item = @model

    @s_type_id = nz(params[:s_type_id], "0").to_i
    @s_admin_gid = nz(params[:s_admin_gid], "0").to_i

    cond = "delete_state = 0"
    cond += " and type_id = #{@s_type_id}" if @s_type_id != 0

    if @s_admin_gid != 0 && @gw_admin
      cond_other_admin = ""
      s_other_admin_group = System::GroupHistory.find_by(id: @s_admin_gid)
      s_other_admin_group
      cond_other_admin = "  "
      if s_other_admin_group.level_no == 2
        gids = Array.new
        gids << @s_admin_gid
        parent_groups = System::GroupHistory.where('parent_id = ?', @s_admin_gid)
        parent_groups.each do |parent_group|
          gids << parent_group.id
        end
        search_group_ids = Gw.join([gids], ',')
        cond_other_admin += " and (auth = 'admin' and  gw_prop_other_roles.gid in (#{search_group_ids}))"
      else
        cond_other_admin += " and (auth = 'admin' and  gw_prop_other_roles.gid = #{s_other_admin_group.id})"
      end
        cond += cond_other_admin
    elsif !@gw_admin
        cond += " and auth = 'admin' and ((gw_prop_other_roles.gid = #{Site.user_group.id}) or (gw_prop_other_roles.gid = 0))" if !@gw_admin
    end

    @items = item.where(cond).joins(:prop_other_roles).group("prop_id").to_a

    parent_groups = Gw::PropOther.get_parent_groups

    @items.sort!{|a, b|
        ag = System::GroupHistory.find_by(id: a.get_admin_first_id(parent_groups))
        bg = System::GroupHistory.find_by(id: b.get_admin_first_id(parent_groups))
        flg = (!ag.blank? && !bg.blank?) ? ag.sort_no <=> bg.sort_no : 0
        (b.reserved_state <=> a.reserved_state).nonzero? or (a.type_id <=> b.type_id).nonzero? or (flg).nonzero? or a.sort_no <=> b.sort_no
    }

    field = []
    field << t("rumi.prop_other.th.type")
    field << t("rumi.prop_other.th.name")
    csv_field = field.join(",") + "\n"
    csv = ""
    @items.each_with_index{ | item, cnt |
      name = item.name
      type_name = item.prop_type.name

      name = name.gsub('"', '""') unless name.blank?
      type_name = type_name.gsub('"', '""') unless type_name.blank?

      csv += "\"#{type_name}\",\"#{name}\"" + "\n"
    }

    if params[:nkf].blank?
      nkf_options = '-Lws'
    else
      nkf_options = case params[:nkf]
      when 'utf8'
        '-w'
      when 'sjis'
        '-Lws'
      end
    end

    filename = "prop_other_lists.csv"
    send_data(NKF::nkf(nkf_options, csv_field + csv), :type => 'text/csv', :filename => filename)
  end


  # === 施設マスタインポートメソッド
  #  本メソッドは施設マスタのCSVインポートを行うメソッドである。
  # ==== 引数
  #  無し
  # ==== 戻り値
  #  無し
  def import_file
    init_params
    Page.title = t("rumi.prop_other.menu.import")
    @piece_head_title = t("rumi.prop_other.menu.import")
    par_item = params[:item]

    if par_item.nil? || par_item[:file].nil?
      flash.now[:notice] = t("rumi.prop_other.message.csv.file") + '<br />'
      respond_to do |format|
        format.html { render :action => "import" }
      end
      return
    end

    # CSVファイル取得
    filename =  par_item[:file].original_filename
    extname = File.extname(filename)
    tempfile = par_item[:file].open

    success = 0
    error = 0
    invalid = 0
    error_msg = ''

    # 拡張子確認
    if extname != '.csv'
      flash.now[:notice] = t("rumi.prop_other.message.csv.type_error") + '<br />'
      respond_to do |format|
        format.html { render :action => "import" }
      end
      return
    end

    require 'csv'
    return if params[:item].nil?
    par_item = params[:item]

    file_data =  NKF::nkf('-w -Lu',tempfile.read)
    csv_result = Array.new

    # ファイルが空
    if file_data.blank?
    else
      csv = CSV.parse(file_data)

      parent_groups = System::GroupHistory.where("level_no = 2").order("sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
      json = []
      json.push ["", Site.user_group.id, Site.user_group.name]
      json = json.to_json
      @admin_json = json
      @editors_json = json

      csv.each_with_index do |row, i|
        _params = Hash::new
        _params[:item] = Hash::new
        item = Gw::PropOther.new
        if i == 0
        elsif row.length == 2
          # 施設種別を取得する
          prop_types = Gw::PropType.where(state: "public", name: row[0]).select("id, name")
          unless prop_types.length == 0
            _params[:item][:sort_no] = ""
            _params[:item][:name] = "#{row[1]}"
            _params[:item][:type_id] = "#{prop_types[0].id}"
            _params[:item][:state] = ""
            _params[:item][:edit_state] = ""
            _params[:item][:delete_state] = ""
            _params[:item][:reserved_state] = 0
            _params[:item][:comment] = ""
            _params[:item][:created_at] = 'now()'
            _params[:item][:updated_at] = ""
            _params[:item][:extra_flag] = ""
            _params[:item][:extra_data] = ""
            _params[:item][:gid] = Site.user_group.id
            _params[:item][:gname] = Site.user_group.name
            _params[:item][:creator_uid] = Site.user.id
            _params[:item][:updater_uid] = ""
            _params[:item][:admin_json] = @admin_json
            _params[:item][:editors_json] = @editors_json
            _params[:item][:readers_json] = @readers_json
            # 未登録の場合は登録を行う
            items = Gw::PropOther.where(name: row[1], type_id: prop_types[0].id)
            if items.length == 0
              if item.save_with_rels_csv _params, :create
                success += 1

              else
                error += 1
                _csv = row.join(",") + ","
                _csv += item.errors.full_messages.join(",")
                csv_result << _csv
              end
            else
              invalid += 1
            end

          else
            error += 1
            _csv = row.join(",") + ","
            _csv += t("rumi.prop_other.message.csv.undefined_type")
            csv_result << _csv
          end
        else
          _csv = row.join(",") + ","
          _csv += t("rumi.prop_other.message.csv.col_count_error")
          csv_result << _csv
          error += 1
        end
      end
    end

    # エラーが存在した場合CSVダウンロード
    if error > 0
      filename += "_result.csv"
      field = []
      field << t("rumi.prop_other.th.type")
      field << t("rumi.prop_other.th.name")
      csv_field = field.join(",") + "\n"
      send_data(NKF::nkf('-Lws', csv_field + csv_result.join("\n")), :type => 'text/csv', :filename => filename)

    # エラーが存在しなかった場合
    else
      _error_msg = t("rumi.prop_other.message.csv.success") + '<br />' +
        t("rumi.prop_other.message.csv.result") + '<br />' +
        t("rumi.prop_other.message.csv.effectiveness") + success.to_s + t("rumi.prop_other.message.csv.effectiveness_tail") +
        t("rumi.prop_other.message.csv.invalid") + invalid.to_s + t("rumi.prop_other.message.csv.invalid_tail") + '<br />'

      if success > 0
        flash[:notice] = _error_msg
        redirect_to gw_prop_others_path
      else
        flash.now[:notice] = _error_msg
        respond_to do |format|
          format.html { render :action => "import" }
        end
      end
    end
  end
end

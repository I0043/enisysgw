# -*- encoding: utf-8 -*-

class Doclibrary::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Rumi::Doclibrary::Authorize
  include Doclibrary::Admin::DocsHelper
  include Doclibrary::Admin::IndicesHelper
  include Doclibrary::Admin::Piece::MenusHelper

  layout "admin/template/portal"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    @piece_head_title = I18n.t("rumi.doclibrary.name")
    @side = "doclibrary"

    # 内容一覧（分類順）画面かどうかのフラグ
    @is_category_index_form =
        (action_name == 'index') && (params[:state] == "CATEGORY" || params[:state].blank?)
    # 検索結果一覧画面かどうかのフラグ
    @is_doc_searching = doc_searching?

    Page.title = @title.title
    
    return redirect_to("#{doclibrary_docs_path}?title_id=#{params[:title_id]}&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]
    admin_flags(@title.id)

    if params[:state].blank?
      params[:state] = 'CATEGORY' unless params[:cat].blank?
      params[:state] = 'GROUP' unless params[:gcd].blank?
      if params[:cat].blank?
        params[:state] = @title.default_folder.to_s if params[:state].blank?
      end if params[:gcd].blank?
    end
    begin
      _search_condition
    rescue
      return http_error(404)
    end
    initialize_value_set
    params[:piece_param] = "TitleDisplayMode"
    get_piece_banners
    get_piece_menus
    level2_groups = System::Group.get_level2_groups
    @level2_groups = []
    level2_groups.each do |g|
      @level2_groups << g.code
    end

  end

  def _search_condition
    group_hash
    category_hash

    case params[:state]
    when 'CATEGORY'
      if params[:cat].blank?
        @parent = @title.folders.root
        params[:cat] = @parent.id.to_s
      else
        @parent = @title.folders.find_by(id: params[:cat])
      end
    else
      if params[:cat].blank?
        @parent = @title.folders.root
      else
        @parent = @title.folders.find_by(id: params[:cat])
      end
    end
  end

  def group_hash
    @groups = Gwboard::Group.level3_all_hash
  end

  # === 閲覧可能フォルダ取得メソッド
  #  本メソッドは、指定ユーザーの閲覧可能なフォルダを取得するメソッドである。
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  閲覧可能フォルダ(Doclibrary::Folder)
  def get_readable_folder(user_id = Core.user.id)
    # 指定ユーザーの所属グループID取得（親グループを含む）
    target_user = System::User.find(user_id)
    user_group_parent_ids = target_user.user_group_parent_ids.join(",")

    str_where  = " (state = 'public' AND doclibrary_folders.title_id = #{@title.id}) AND ((acl_flag = 0)"
    if @gw_admin
      str_where  += " OR (acl_flag = 9))"
    elsif user_group_parent_ids.size != 0
        str_where  += " OR (acl_flag = 1 AND acl_section_id IN (#{user_group_parent_ids}))"
        str_where  += " OR (acl_flag = 2 AND acl_user_id = #{target_user.id}))"
    else
        str_where  += ")"
    end

    str_sql = 'SELECT doclibrary_folders.id FROM doclibrary_folder_acls, doclibrary_folders'
    str_sql += ' WHERE doclibrary_folder_acls.folder_id = doclibrary_folders.id'
    str_sql += ' AND ( ' + str_where + ' )'
    str_sql += ' GROUP BY doclibrary_folders.id'

    items = Doclibrary::ViewAclFolder.find_by_sql(str_sql)
    folder_ids = items.map{|f| f.id}.join(",")

    folders = []
    unless folder_ids.blank?
      folders = Doclibrary::Folder.where("id IN (#{folder_ids})")
                                  .order("sort_no, id")
    end
    return folders
  end

  def category_hash
    @categories = Doclibrary::Folder.where(state: 'public', title_id: params[:title_id])
                                    .select('id, name').index_by(&:id)
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable
    return authentication_error(403) if @is_category_index_form && !@parent.readable_user?

    if @title.form_name == 'form002'
      index_form002
    else
      index_form001
    end
  end

  def index_form001
    case params[:state]
    when 'DRAFT'
      category_folder_items('draft') unless doc_searching?
      normal_draft_index
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      category_folder_items unless doc_searching?
      normal_category_index_form001
    end

    # キーワードが入力された場合のみ、添付ファイル一覧を表示
    search_files_index unless params[:kwd].blank?

    begin
      # 一括ダウンロードボタンがクリックされた場合、ファイルのダウンロード実行
      export_zip_file unless params[:download].blank?
    rescue => ex
      flash.now[:error] = ex.message
    end
  end

  def index_form002
    unless params[:kwd].blank?
      search_index_docs
    else
      if params[:state].to_s== 'DRAFT'
       normal_draft_index_form002
      else
       normal_category_index
      end
    end
  end

  def new
    get_role_new

    # ファイル作成できるか？（いずれかのフォルダに管理権限があるか？）
    return authentication_error(403) unless @has_some_folder_admin

    # カレントフォルダに管理権限があるか?
    category1_id = params[:cat]
    unless params[:cat].blank?
      folder = Doclibrary::Folder.find(params[:cat])
      unless folder.present? && folder.admin_user?
        # カレントフォルダに管理権限がない場合、フォルダの初期値クリア
        category1_id = ""
      end
    end

    str_section_code = Core.user_group.code
    str_section_code = params[:gcd].to_s unless params[:gcd].to_s == '1' unless params[:gcd].blank?
    @item = Doclibrary::Doc.create({
      :state => 'preparation',
      :title_id => @title.id ,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :section_code => str_section_code ,
      :category4_id => 0,
      :category1_id => category1_id
    })

    @item.state = 'draft'

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    users_collection unless @title.recognize == 0
  end

  def is_i_have_readable(folder_id)
    return true if @is_recognize_readable
    return false if folder_id.blank?
    p_grp_code = ''
    p_grp_code = Core.user_group.parent.code unless Core.user_group.parent.blank?
    grp_code = ''
    grp_code = Core.user_group.code unless Core.user_group.blank?

    sql = Condition.new
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :folder_id, folder_id
      d.and :acl_flag , 0
    }
    if @gw_admin

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 9
      }
    else

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 1
        d.and :acl_section_code , p_grp_code
      }

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 1
        d.and :acl_section_code , grp_code
      }

      sql.or {|d|
        d.and :title_id , @title.id
        d.and :folder_id, folder_id
        d.and :acl_flag , 2
        d.and :acl_user_code , Core.user.code
      }
    end
    items = Doclibrary::FolderAcl.where(sql.where)
    return false if items.blank?
    return false if items.count == 0
    return true unless items.count == 0
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    admin_flags(params[:title_id])

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    @item = Doclibrary::Doc.where(id: params[:id]).first
    return http_error(404) unless @item
    get_role_show(@item)
    Page.title = @item.title
    @parent = @item.parent
    return authentication_error(403) unless @parent.readable_user?

    unless @gw_admin
      if @item.state=='draft'
        user_groups = Core.user.enable_user_groups
        user_groups_code = user_groups.map{|group| group.group_code} unless user_groups.blank?
        unless user_groups_code.present? || user_groups_code.include?(@item.section_code)
          return http_error(404)
        end
      end
    end

    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)
    @is_readable = true if @is_recognize_readable
    return authentication_error(403) unless @is_readable

    item = Doclibrary::File.where(title_id: @title.id)
    item = item.where(parent_id: @item.id) unless @title.form_name == 'form002'
    item = item.where(parent_id: @item.category2_id) if @title.form_name == 'form002'
    @files = item.order('id')

    get_recogusers
    @is_publish = true if @gw_admin if @item.state == 'recognized'
    user_groups = Core.user.enable_user_groups
    user_groups_code = user_groups.map{|group| group.group_code} unless user_groups.blank?
    if user_groups_code.present? && user_groups_code.include?(@item.section_code)
      @is_publish = true if @item.state == 'recognized'
    end
  end

  def edit
    get_role_new

    @item = Doclibrary::Doc.where(id: params[:id]).first
    return http_error(404) unless @item

    # ファイルを編集できるか？（ファイルの親フォルダに管理権限があるか？）
    return authentication_error(403) unless @item.parent.admin_user?

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end

    # 編集開始日時の取得
    @edit_start = Time.now
    params[:edit_start] = @edit_start if params[:edit_start].blank?
  end

  def update
    get_role_new

    @item = Doclibrary::Doc.find(params[:id])
    return http_error(404) unless @item

    set_folder_level_code
    form002_categories if @title.form_name == 'form002'
    unless @title.recognize.to_s == '0'
      users_collection
    end

    @files = Doclibrary::File.where(title_id: @title.id, parent_id: params[:id])
                             .order('id')
    attach = 0
    attach = @files.length unless @files.blank?

    @item = Doclibrary::Doc.find(params[:id])
    @item.attributes = item_params
    @item._recognizers = params[:item]["_recognizers"]
    @item._recognition = params[:item]["_recognition"]
    @item.latest_updated_at = Time.now
    @item.attachmentfile = attach
    @item.category_use = 1
    @item.form_name = @title.form_name

    group = Gwboard::Group.where(state: 'enabled', code: @item.section_code).first
    @item.section_name = group.name if group
    @item._note_section = group.name if group

    update_creater_editor

    section_folder_state_update

    if @title.notification == 1
      notes = Doclibrary::FolderAcl.where(title_id: @title.id, folder_id: @item.category1_id)
                                   .where("acl_flg < ?", 9)
      @item._acl_records = notes
      @item._notification = @title.notification
      @item._bbs_title_name = @title.title
    end

    if @title.recognize == 0
      _update_plus_location @item, doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params, {notice: params[:message]}
    else
      _update_after_save_recognizers(@item, Doclibrary::Recognizer, doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params)
    end
  end

  def destroy
    @item = Doclibrary::Doc.find(params[:id])

    get_role_edit(@item)

    # ファイル削除できるか？（ファイルの親フォルダに管理権限があるか？）
    return authentication_error(403) unless @item.parent.admin_user?

    destroy_atacched_files
    #destroy_files

    @item._notification = @title.notification
    _destroy_plus_location @item,doclibrary_docs_path({:title_id=>@title.id}) + doclib_uri_params
  end

  def edit_file_memo
    get_role_index
    return authentication_error(403) unless @is_readable

    @item = Doclibrary::Doc.where(id: params[:parent_id]).first
    return http_error(404) unless @item
    get_role_show(@item)

    item = Doclibrary::File.where(title_id: @title.id)
    item = item.where(parent_id: @item.id) unless @title.form_name == 'form002'
    item = item.where(parent_id: @item.category2_id) if @title.form_name == 'form002'
    @files = item.order('id')

    @file = Doclibrary::File.find(params[:id])
  end

  def docs_state_from_params
    case params[:state]
    when 'DRAFT'
      'draft'
    when 'RECOGNIZE'
      'recognize'
    when 'PUBLISH'
      'recognized'
    else
      'public'
    end
  end

  def search_files_index
    item = Doclibrary::ViewAclFile.joins(:parent).where(title_id: @title.id, docs_state: docs_state_from_params)
                                  .search(params)

    # ログインユーザーの所属グループコードを取得（親グループを含む）
    user_group_parent_codes = []
    Core.user.enable_user_groups.each do |user_group|
      user_group_parent_codes += user_group.group.parent_tree.map(&:code)
    end
    user_group_parent_codes.uniq!
    sql = Condition.new
    case params[:state]
    when 'DATE'
      item = item.where(section_code: params[:gcd]) unless params[:gcd].blank?
      item = item.where(category1_id: params[:cat]) unless params[:cat].blank?
    when 'GROUP'
      item = item.where(section_code: section_codes_narrow_down) unless params[:gcd].blank?
      item = item.where(category1_id: params[:cat]) unless params[:cat].blank?
    when 'CATEGORY'
      item = item.where(section_code: params[:gcd]) unless params[:gcd].blank?
      item = item.where(category1_id: category_ids_narrow_down) unless params[:kwd].blank?
      item = item.where(category1_id: params[:cat]) unless params[:cat].blank? if params[:kwd].blank?
    when 'DRAFT', 'PUBLISH'
      item = item.where(section_code: user_group_parent_codes) unless @gw_admin
    end

    sql.or {|d2|
      d2.and "doclibrary_view_acl_files.acl_flag", 0
    }
    if @gw_admin
      sql.or {|d2|
        d2.and "doclibrary_view_acl_files.acl_flag", 9
      }
    else
      sql.or {|d2|
        d2.and "doclibrary_view_acl_files.acl_flag", 1
        d2.and "doclibrary_view_acl_files.acl_section_code", user_group_parent_codes
      }
      sql.or {|d2|
        d2.and "doclibrary_view_acl_files.acl_flag", 2
        d2.and "doclibrary_view_acl_files.acl_user_code", Core.user.code
      }
    end
    item = item.where(sql.where)
    case params[:state]
    when 'DATE'
      item = item.order "doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC, doclibrary_view_acl_files.filename"
    when 'GROUP'
      item = item.order "doclibrary_view_acl_files.section_code, doclibrary_view_acl_files.category1_id, doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC, doclibrary_view_acl_files.filename"
    else
      item = item.order "doclibrary_view_acl_files.filename, doclibrary_view_acl_files.updated_at DESC, doclibrary_view_acl_files.created_at DESC"
    end

    @files = item.group('doclibrary_view_acl_files.id').paginate_doclibrary(params)
  end

  def section_codes_narrow_down
    section_codes = []
    unless params[:gcd].blank?
      items = Doclibrary::GroupFolder.where(title_id: @title.id, state: 'public', code: params[:gcd].to_s)
      section_codes += section_narrow(items) if items
    end
    section_codes
  end
  def section_narrow(items)
    section_codes = []
    items.each do |item|
      section_codes << item.code
      section_narrow(item.children) if item.children.size > 0
    end
    section_codes
  end

  def normal_category_index_form001
    user_groups_code = Core.user.user_group_parent_codes

    item = Doclibrary::Doc.where(state: 'public', title_id: @title.id)
    item = item.where(item.get_keywords_condition(params[:kwd], :title, :body).where) unless params[:kwd].blank?
    item = item.where(item.get_creator_condition(params[:creator], :creater, :createrdivision_id).where) unless params[:creator].blank?
    item = item.where(
        item.get_date_condition(params[:term_start],
        'doclibrary_docs.created_at', {:is_term_start => true}).where) if params[:term_start].present?
    item = item.where(
        item.get_date_condition(params[:term_finish],
        'doclibrary_docs.created_at', {:is_term_start => false}).where) if params[:term_finish].present?
    case params[:state]
    when 'DATE'
      item = item.where(section_code:  params[:gcd]) unless params[:gcd].blank?
      item = item.where(category1_id:  params[:cat]) unless params[:cat].blank?
    when 'GROUP'
      item = item.where(section_code:  section_codes_narrow_down) unless params[:gcd].blank?
      item = item.where(category1_id:  params[:cat]) unless params[:cat].blank?
    when 'CATEGORY'
      item = item.where(section_code:  params[:gcd]) unless params[:gcd].blank?
      item = item.where(category1_id:  category_ids_narrow_down) if doc_searching?
      item = item.where(category1_id:  params[:cat]) unless params[:cat].blank? unless doc_searching?
    end

    sql = Condition.new
    sql.or {|d2|
      d2.and 'doclibrary_view_acl_docs.acl_flag', 0
    }
    if @gw_admin
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 9
      }
    else
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 1
        d2.and 'doclibrary_view_acl_docs.acl_section_code', user_groups_code unless user_groups_code.blank?
      }
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 1
        d2.and 'doclibrary_view_acl_docs.acl_section_id', 0
      }
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 2
        d2.and 'doclibrary_view_acl_docs.acl_user_code', Core.user.code
      }
    end
    item = item.where(sql.where)

    case params[:state]
    when 'DATE'
      item = item.order("doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title")
    when 'GROUP'
      item = item.order("doclibrary_docs.section_code, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC")
    else
      item = item.order("doclibrary_view_acl_docs.sort_no, section_code, doclibrary_docs.title, doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC")
    end

    item = item.joins('INNER JOIN doclibrary_view_acl_docs ON doclibrary_docs.id = doclibrary_view_acl_docs.id')
    #item.page params[:page], params[:limit]
    select = "doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id, doclibrary_docs.section_name"
    @items = item.select(select).group('doclibrary_docs.id').paginate_doclibrary(params)
  end

  def category_ids_narrow_down
    cats = []
    unless params[:cat].blank?
      items = Doclibrary::Folder.where(title_id: @title.id, state: 'public', id: params[:cat])
                                .select('id')
      cats += category_narrow(items) if items
    end
    cats
  end

  def category_narrow(items)
    cats = []
    items.each do |item|
      cats << item.id
      cats += category_narrow(item.children.where(:state => 'public'))
    end
    cats
  end

  def search_index_docs
    @items = Doclibrary::Doc.where(state: 'public', title_id: params[:title_id])
                            .search(params)
                            .order("inpfld_001 , inpfld_002 DESC, inpfld_003, inpfld_004, inpfld_005, inpfld_006")
                            .paginate_doclibrary(params)
  end

  def normal_category_index
    category_folder_items unless doc_searching?

    if @title.form_name == 'form002'
      normal_category_index_form002
    else
      normal_category_index_form001
    end
  end

  def category_folder_items(state=nil)
    folder = Doclibrary::Folder.find_by(id: params[:cat])

    if folder.blank?
      level_no = 2
      parent_id = 1
    else
      level_no = folder.level_no + 1
      parent_id = folder.id
    end

    item = Doclibrary::ViewAclFolder.where(state: state == 'draft' ? 'closed' : 'public', title_id: @title.id)
    item = item.where(level_no: level_no) unless state == 'draft'
    item = item.where(parent_id: parent_id) unless state == 'draft'
    
    sql = Condition.new
    sql.or {|d2|
      d2.and :acl_flag, 0
    }
    if @gw_admin
      sql.or {|d2|
        d2.and :acl_flag, 9
      }
    else
      sql.or {|d2|
        d2.and :acl_flag, 1
        d2.and :acl_section_id, Core.user.user_group_parent_ids
      }
      sql.or {|d2|
        d2.and :acl_flag, 1
        d2.and :acl_section_id, 0
      }
      sql.or {|d2|
        d2.and :acl_flag, 2
        d2.and :acl_user_id, Core.user.id
      }
    end
    @folders = item.where(sql.where).order("level_no, sort_no, id").group(:id)
                   .paginate_doclibrary(params)
  end

  def normal_category_index_form002
    @items = Doclibrary::Doc.where(state: 'public', title_id: params[:title_id], category1_id: params[:cat])
                            .order("inpfld_001, inpfld_002 DESC, inpfld_003 DESC, inpfld_004 DESC, inpfld_005, inpfld_006")
                            .paginate_doclibrary(params)
  end

  def normal_draft_index
    user_groups = Core.user.enable_user_groups
    user_groups_code = user_groups.map{|group| group.group_code} unless user_groups.blank?
    item = Doclibrary::Doc.where(title_id: @title.id, state: 'draft')
    unless params[:gcd].blank?
      item = item.where(section_code:  params[:gcd])
    else
      item = item.where(section_code: user_groups_code) unless user_groups_code.blank? unless @gw_admin
    end
    item = item.where(item.get_keywords_condition(params[:kwd], :title, :body).where) unless params[:kwd].blank?
    item = item.where(item.get_creator_condition(params[:creator], :creater, :createrdivision_id).where) unless params[:creator].blank?
    item = item.where(
        item.get_date_condition(params[:term_start],
        'doclibrary_docs.created_at', {:is_term_start => true}).where) if params[:term_start].present?
    item = item.where(
        item.get_date_condition(params[:term_finish],
        'doclibrary_docs.created_at', {:is_term_start => false}).where) if params[:term_finish].present?

    sql = Condition.new
    sql.or {|d2|
      d2.and 'doclibrary_view_acl_docs.acl_flag', 0
      d2.and 'doclibrary_view_acl_folders.state', "public"
    }
    if @gw_admin
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 9
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    else
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 1
        d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 2
        d2.and 'doclibrary_view_acl_docs.acl_user_code', Core.user.code
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    end
    
    item = item.where(sql.where).joins('INNER JOIN doclibrary_view_acl_docs ON doclibrary_docs.id = doclibrary_view_acl_docs.id INNER JOIN doclibrary_view_acl_folders ON doclibrary_docs.category1_id = doclibrary_view_acl_folders.id')
    item = item.order("doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title")
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id, doclibrary_docs.section_name"
    @items = item.select(select).group('doclibrary_docs.id').paginate_doclibrary(params)
  end

  def recognize_index
    item = Doclibrary::Doc.where(title_id: @title.id, state: 'recognize')
    item = item.where(item.get_keywords_condition(params[:kwd], :title, :body).where) unless params[:kwd].blank?
    item = item.where(item.get_creator_condition(params[:creator], :creater, :createrdivision_id).where) unless params[:creator].blank?
    item = item.where(
        item.get_date_condition(params[:term_start],
        'doclibrary_docs.created_at', {:is_term_start => true}).where) if params[:term_start].present?
    item = item.where(
        item.get_date_condition(params[:term_finish],
        'doclibrary_docs.created_at', {:is_term_start => false}).where) if params[:term_finish].present?

    sql = Condition.new
    sql.or {|d2|
      d2.and 'doclibrary_view_acl_docs.acl_flag', 0
      d2.and 'doclibrary_view_acl_folders.state', "public"
    }
    if @gw_admin
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 9
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    else
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 1
        d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 2
        d2.and 'doclibrary_view_acl_docs.acl_user_code', Core.user.code
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    end

    unless params[:gcd].blank?
      item = item.where(section_code:  params[:gcd])
    else
      unless @gw_admin
          user_groups = Core.user.enable_user_groups
          user_groups_code = user_groups.map{|group| group.group_code} unless user_groups.blank?
          sql.or "doclibrary_docs.section_code", user_groups_code unless user_groups_code.blank?
          sql.or "doclibrary_recognizers.code", Core.user.code
          sql.or "doclibrary_docs.creater_id", Core.user.code
      end
    end
    
    item = item.where(sql.where).joins("INNER JOIN doclibrary_recognizers ON " +
        "doclibrary_docs.id = doclibrary_recognizers.parent_id AND " +
        "doclibrary_docs.title_id = doclibrary_recognizers.title_id " +
        "INNER JOIN doclibrary_view_acl_folders ON " +
        "doclibrary_docs.category1_id = doclibrary_view_acl_folders.id " +
        "INNER JOIN doclibrary_view_acl_docs ON " +
        "doclibrary_docs.id = doclibrary_view_acl_docs.id").order('latest_updated_at DESC')
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id, doclibrary_docs.section_name"
    #@items = item.select(select).group('doclibrary_docs.id').paginate(page: params[:page]).limit(params[:limit].to_i)
    @items = item.select(select).group('doclibrary_docs.id').paginate_doclibrary(params)
  end

  def recognized_index
    item = Doclibrary::Doc.where(title_id: @title.id, state: 'recognized')

    user_groups = Core.user.enable_user_groups
    user_groups_code = user_groups.map{|group| group.group_code} unless user_groups.blank?
    unless params[:gcd].blank?
      item = item.where(section_code:  params[:gcd])
    else
      item = item.where(section_code: user_groups_code) unless user_groups_code.blank? unless @gw_admin
    end
    item = item.where(item.get_keywords_condition(params[:kwd], :title, :body).where) unless params[:kwd].blank?
    item = item.where(item.get_creator_condition(params[:creator], :creater, :createrdivision_id).where) unless params[:creator].blank?
    item = item.where(
        item.get_date_condition(params[:term_start],
        'doclibrary_docs.created_at', {:is_term_start => true}).where) if params[:term_start].present?
    item = item.where(
        item.get_date_condition(params[:term_finish],
        'doclibrary_docs.created_at', {:is_term_start => false}).where) if params[:term_finish].present?
    sql = Condition.new
    sql.or {|d2|
      d2.and 'doclibrary_view_acl_docs.acl_flag', 0
      d2.and 'doclibrary_view_acl_folders.state', "public"
    }
    if @gw_admin
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 9
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    else
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 1
        d2.and 'doclibrary_view_acl_docs.acl_section_code', Site.parent_user_groups.map{|g| g.code}
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
      sql.or {|d2|
        d2.and 'doclibrary_view_acl_docs.acl_flag', 2
        d2.and 'doclibrary_view_acl_docs.acl_user_code', Core.user.code
        d2.and 'doclibrary_view_acl_folders.state', "public"
      }
    end
    item = item.where(sql.where).joins('inner join doclibrary_view_acl_docs on doclibrary_docs.id = doclibrary_view_acl_docs.id INNER JOIN doclibrary_view_acl_folders ON doclibrary_docs.category1_id = doclibrary_view_acl_folders.id')
    item = item.order("doclibrary_docs.updated_at DESC, doclibrary_docs.created_at DESC, doclibrary_view_acl_docs.sort_no, doclibrary_docs.category1_id, doclibrary_docs.title")
    select = "DISTINCT doclibrary_docs.id, doclibrary_docs.state, doclibrary_docs.updated_at, doclibrary_docs.latest_updated_at, "
    select += "doclibrary_docs.parent_id, doclibrary_docs.section_code, doclibrary_docs.title, doclibrary_docs.title_id, doclibrary_docs.category1_id, doclibrary_docs.section_name"
    @items = item.select(select).group('doclibrary_docs.id').paginate_doclibrary(params)
  end

  def normal_draft_index_form002
    folder = Doclibrary::Folder.find_by(id: params[:cat])

    params[:cat] = 1 if folder.blank?
    level_no = 2 if folder.blank?
    parent_id = 1 if folder.blank?

    level_no = folder.level_no + 1 unless folder.blank?
    parent_id = folder.id unless folder.blank?

    @folders = Doclibrary::Folder.where(state: 'public', title_id: @title.id, level_no: level_no, parent_id: parent_id)
               .order("level_no, sort_no, id").paginate_doclibrary(params)
    @folders = item.order("level_no, sort_no, id")

    str_order = "updated_at DESC, created_at DESC, category1_id, id" unless @title.form_name == 'form002'
    str_order = "inpfld_001 , inpfld_002 DESC, inpfld_003, inpfld_004, inpfld_005, inpfld_006" if @title.form_name == 'form002'
    @items = Doclibrary::Doc.where(state: 'draft', title_id: @title.id, category1_id: params[:cat])
                            .order(str_order).pagiante(page: params[:page]).limit(params[:limit])
  end

  def set_folder_level_code
    items = Doclibrary::GroupFolder.where(title_id: @title.id, level_no: 1, state: 'public')
                                       .order('level_no, sort_no, parent_id, id')
    @group_levels = []
    set_folder_hash('group', items)

    items = Doclibrary::Folder.where(title_id: @title.id, level_no: 1)
                              .order('level_no, sort_no, parent_id, id')
    @category_levels = []
    set_folder_hash('category', items)

    # 管理権限なしフォルダのID取得
    @without_admin_folders = Doclibrary::Folder.without_admin_auth(@title.id)
  end

  def set_folder_hash(mode, items)
    if items.size > 0
      items.each do |item|
        if item.state == 'public'
          tree = '+'
          tree += "-" * (item.level_no - 2) if 0 < (item.level_no - 2)
          @group_levels << [tree + item.code + item.name, item.code] if mode == 'group'
          @category_levels << [tree + item.name, item.id] if 1 <= item.level_no unless mode == 'group'
          case mode
          when 'group'
            children = item.children
          when 'category'
            children = item.readable_public_children(@gw_admin)
          end
          set_folder_hash(mode, children)
        end
      end
    end
  end

  def section_folder_state_update
    item = Doclibrary::Doc.where(state: 'public', title_id: @title.id)
                        .select('section_code').group('section_code').each do |code|
                          g_item = Doclibrary::GroupFolder.where(title_id: @title.id, code: code.section_code).each do |group|
                            group_state_rewrite(group,Doclibrary::GroupFolder)
                          end
                       end
  end

  def group_state_rewrite(item,group_item)
    group_item.update(item.id, :state =>'public')
    unless item.parent.blank?
      group_state_rewrite(item.parent, group_item)
    end
  end

  def form002_categories
    if @title.form_name == 'form002'
      @documents = []
    end
  end


  def set_form002_params
      item = []
      if item
        @item.inpfld_001 = item.wareki
        @item.inpfld_002 = item.nen
        @item.inpfld_003 = item.gatsu
        @item.inpfld_004 = item.sono
        @item.inpfld_005 = item.sono2

        @item.inpfld_007 = "#{@item.inpfld_004.to_s} - #{item.sono2}" unless item.sono2.blank?
        @item.inpfld_007 = item.sono if item.sono2.blank?
      end
  end

  def is_attach_new
    ret = false
    case @title.upload_system
    when 1..4
      ret = true
    end
    return ret
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end

  def get_recogusers
    @recogusers = Doclibrary::Recognizer.where(title_id: @title.id, parent_id: params[:id]).order('id')
  end

  def publish_update
    item = Doclibrary::Doc.where(state: 'recognized', title_id: @title.id, id: params[:id]).first
    if item
      item.state = 'public'
      item.published_at = Time.now
      item.save
    end

    # 作成者、または承認者が公開処理を行った場合、
    # 作成者への承認完了の新着情報を既読にする
    item.seen_approve_remind

    redirect_to(doclibrary_docs_path({:title_id=>@title.id}))
  end

  def recognize_update
    item = Doclibrary::Recognizer.where(title_id: @title.id, parent_id: params[:id], code: Core.user.code).first
    if item
      item.recognized_at = Time.now
      item.save
    end

    item = Doclibrary::Recognizer.where(title_id: @title.id, parent_id: params[:id])
    item = item.where("recognized_at IS NULL")
    recognizer_count = item.length

    item = Doclibrary::Doc.find(params[:id])
    @parent = item.parent

    # 承認依頼の新着情報を既読にする
    item.seen_request_remind(Core.user.id)

    if recognizer_count == 0
      item.state = 'recognized'
      item.recognized_at = Time.now
      item.save

      # 承認者全員が承認した場合、承認完了の新着情報を作成する
      item.build_approve_remind

      user = System::User.find_by_code(item.editor_id.to_s)
      unless user.blank?
        Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{doclibrary_show_uri(item,params)}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
      end
    end

    get_role_new

    redirect_to_url = "#{doclibrary_docs_path({:title_id=>@title.id})}"
    if @parent.admin_user?
      redirect_to_url += "&state=RECOGNIZE"
    end
    redirect_to(redirect_to_url)
  end

  def check_recognize
    item = Doclibrary::Recognizer.where(title_id: @title.id, parent_id: params[:id], code: Core.user.code)
    item = item.where("recognized_at is null")
    ret = nil
    ret = true if item.length != 0
    return ret
  end

  def check_recognize_readable
    item = Doclibrary::Recognizer.where(title_id: @title.id, parent_id: params[:id], code: Core.user.code)
    ret = nil
    ret = true if item.length != 0
    return ret
  end


  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_atacched_files
    Doclibrary::File.where(sql_where).destroy_all
  end

  # === 検索結果一覧画面かどうかの判定メソッド
  #  検索結果一覧画面かどうかを判定するメソッドである。
  #  判定方法は検索項目に入力データがあるかどうかで判定する。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  検索結果一覧画面の場合はTrue、検索結果一覧画面でない場合Falseを戻す
  def doc_searching?
    return true if params[:kwd].present?
    return true if params[:gcd].present?
    return true if params[:creator].present?
    return true if params[:term_start].present?
    return true if params[:term_finish].present?
    return false
  end

  # === ファイル一括ダウンロード用メソッド
  #  本メソッドは、ファイルを一括ダウンロードするメソッドである。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def export_zip_file
    # ファイルが選択されていない場合、例外を発生して終了
    if params[:file_check].blank?
      raise I18n.t('rumi.doclibrary.message.attached_file_not_selected')
    end

    # 現在選択中のファイルID配列
    selected_file_id = params[:file_check].map{|id| id.to_i}

    # 選択されたファイルを取得
    files = Doclibrary::Doc.where(title_id: @title.id, id: selected_file_id)

    # zipファイル情報取得
    zip_data = {}
    for file in files
      # 分類フォルダと同じフォルダ階層を取得
      parent = Doclibrary::Folder.find_by(id: file.category1_id)
      tree = "#{parent.id.to_s}_#{parent.name}"
      tree_path = File.join(tree)

      # フォルダ階層の末尾に「ファイルID_ファイル名」フォルダを追加
      tree_path = File.join(tree_path, "#{file.id.to_s}_#{file.title}")

      # ファイルに登録されている添付ファイルを取得
      attache_files = Doclibrary::File.where(title_id: @title.id, parent_id: file.id)
                                      .order('id')

      if attache_files.count == 0
        # 添付ファイルが未登録の場合、zipファイルへフォルダのみ作成する
        # zipファイル情報の保存
        zip_data[tree_path] = ''
      else
        # zipファイルへフォルダと添付ファイルを作成する
        for attache_file in attache_files
          # zipファイル情報の保存
          zip_data[File.join(tree_path, "#{attache_file.id}_#{attache_file.filename}")] =
              attache_file.f_name
        end
      end
    end

    # 一時フォルダの存在チェックとフォルダ作成
    unless File.exist?(Rumi::Doclibrary::ZipFileUtils::TMP_FILE_PATH)
      FileUtils.mkdir_p(Rumi::Doclibrary::ZipFileUtils::TMP_FILE_PATH)
    end

    # 一時ファイル名
    target_zip_file = File.join(
        Rumi::Doclibrary::ZipFileUtils::TMP_FILE_PATH,
        "#{request.session_options[:id]}.zip")

    # zipファイルの作成
    Rumi::Doclibrary::ZipFileUtils.zip(
        target_zip_file,
        zip_data,
        {:fs_encoding => Rumi::Doclibrary::ZipFileUtils::ZIP_ENCODING})

    # ダウンロードファイル名
    download_file_name = "doclibrary_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
    send_file target_zip_file ,
        :filename => download_file_name if FileTest.exist?(target_zip_file)
    # 一時ファイルの削除
    #File.delete target_zip_file if FileTest.exist?(target_zip_file)

  end

  # === ファイルドラッグ＆ドロップ（移動/コピー）用メソッド
  #  本メソッドは、ファイルをドラッグ＆ドロップ（移動/コピー）するメソッドである。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def files_drag
    begin
      # 移動（コピー）元ファイルIDの取得
      file_ids = params[:item][:ids].split(",")
      raise if file_ids.blank?

      # 移動（コピー）先フォルダIDの取得
      folder_id = params[:item][:folder]
      raise if folder_id.blank?

      # ファイル／フォルダ操作（移動/コピー）の取得
      drag_option = (params[:drag_option].blank?)? 0 : params[:drag_option].to_i

      if drag_option == 1
        error_message = I18n.t('rumi.doclibrary.drag_and_drop.message.file_copy_error')

        # ファイルコピー
        file_ids.each do |file_id|
          copy_file(file_id, folder_id)
        end

        # 添付ファイルの使用容量の更新（DB更新の有無に関わらず実行）
        update_total_file_size

        # ファイルコピー完了メッセージ
        flash[:file_drag_message] = I18n.t('rumi.doclibrary.drag_and_drop.message.copy_file')
      else
        error_message = I18n.t('rumi.doclibrary.drag_and_drop.message.file_move_error')

        # ファイル移動
        file_ids.each do |file_id|
          move_file(file_id, folder_id)
        end

        # ファイル移動完了メッセージ
        flash[:file_drag_message] = I18n.t('rumi.doclibrary.drag_and_drop.message.move_file')
      end
    rescue => ex
      if ex.message.length == 0
        flash[:file_drag_message] = error_message
      else
        flash[:file_drag_message] = ex.message
      end
    end

    return redirect_to(doclibrary_docs_path({:title_id=>@title.id}) + doclib_params_set)
  end

  # === フォルダドラッグ＆ドロップ（移動、コピー）用メソッド
  #  本メソッドは、ファイルをドラッグ＆ドロップ（移動、コピー）するメソッドである。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def folder_drag
    begin
      # 移動（コピー）対象フォルダIDの取得
      src_folder_id = params[:item][:src_folder]
      raise if src_folder_id.blank?

      # 移動（コピー）先フォルダIDの取得
      dst_folder_id = params[:item][:dst_folder]
      raise if dst_folder_id.blank?

      # ファイル／フォルダ操作（移動/コピー）の取得
      drag_option = (params[:drag_option].blank?)? 0 : params[:drag_option].to_i

      if drag_option == 1
        error_message = I18n.t('rumi.doclibrary.drag_and_drop.message.folder_copy_error')

        # フォルダコピー
        copy_folder(src_folder_id, dst_folder_id)

        # 添付ファイルの使用容量の更新（DB更新の有無に関わらず実行）
        update_total_file_size

        # フォルダコピー完了メッセージ
        flash[:folder_drag_message] = I18n.t('rumi.doclibrary.drag_and_drop.message.copy_folder')
      else
        error_message = I18n.t('rumi.doclibrary.drag_and_drop.message.folder_move_error')

        # フォルダ移動
        move_folder(src_folder_id, dst_folder_id)

        # フォルダ移動完了メッセージ
        flash[:folder_drag_message] = I18n.t('rumi.doclibrary.drag_and_drop.message.move_folder')
      end
    rescue => ex
      if ex.message.length == 0
        flash[:folder_drag_message] = error_message
      else
        flash[:folder_drag_message] = ex.message
      end
    end

    return redirect_to(doclibrary_docs_path({:title_id=>@title.id}) + doclib_params_set)
  end

  # === 添付ファイル利用容量更新メソッド
  #  本メソッドは、添付ファイル、画像ファイルの利用容量を更新するメソッドである。
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def update_total_file_size
    total = Doclibrary::File.where('unid = 1').sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f

    total = Doclibrary::File.where('unid = 2').sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f

    @title.save
  end


protected

  # === ファイル移動メソッド
  #  本メソッドは、ファイルを移動するメソッドである。
  # ==== 引数
  #  * file_id: ファイルID
  #  * folder_id: 移動先フォルダID
  # ==== 戻り値
  #  なし
  def move_file(file_id, folder_id)
    begin
      # 移動元ファイルの取得
      src_file = Doclibrary::Doc.find_by(id: file_id)
      if src_file.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_move_file_not_found')
      end

      # ファイルの移動先フォルダが現在のフォルダの場合、終了
      if src_file.category1_id == folder_id.to_i
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_movement')
      end

      # 移動元フォルダの取得
      src_folder = Doclibrary::Folder.find_by(id: src_file.category1_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_move_folder_not_found')
      end

      # 移動先フォルダの取得
      dst_folder = Doclibrary::Folder.find_by(id: folder_id)
      if dst_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_move_folder_not_found')
      end

      # 移動元フォルダ、移動先フォルダへの管理権限があるかをチェック
      unless src_folder.admin_user?(Core.user.id) &&
          dst_folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      begin
        Doclibrary::Doc.transaction do
          begin
            Doclibrary::File.transaction do
              begin
                # == ファイル移動 ==
                # ファイル情報変更
                src_file.category1_id = folder_id
                # 更新者情報変更
                src_file.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
                src_file.editor = Core.user.name unless Core.user.name.blank?
                src_file.editordivision =
                    Core.user_group.name unless Core.user_group.name.blank?
                src_file.editor_id = Core.user.code unless Core.user.code.blank?
                src_file.editordivision_id =
                    Core.user_group.code unless Core.user_group.code.blank?
                src_file.editor_admin = (@gw_admin)? true : false
                src_file.latest_updated_at = Time.now
                src_file.save!

                # 移動ファイルの添付ファイル情報を取得
                attach_files =
                    Doclibrary::File.where("parent_id = #{src_file.id}")
                # 添付ファイルについて情報変更
                attach_files.each do |attach_file|
                  attach_file.updated_at = Time.now
                  attach_file.save!
                end
              end
            end
          rescue
            raise # エラーメッセージは上位メソッドで表示
          end
        end
      rescue
        raise # エラーメッセージは上位メソッドで表示
      end
    rescue => ex
      raise ex.message
    ensure
    end
  end

  # === ファイルコピーメソッド
  #  本メソッドは、ファイルをコピーするメソッドである。
  # ==== 引数
  #  * file_id: ファイルID
  #  * folder_id: コピー先フォルダID
  #  * is_folder_copy: フォルダーコピー処理中のファイルコピーか？（True:フォルダーコピー / False:ファイルコピー）
  # ==== 戻り値
  #  なし
  def copy_file(file_id, folder_id, is_folder_copy=false)
    begin
      # コピー元ファイルの取得
      src_file = Doclibrary::Doc.find_by(id: file_id)
      if src_file.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_copy_file_not_found')
      end

      # コピー元フォルダの取得
      src_folder = Doclibrary::Folder.find_by(id: src_file.category1_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_copy_folder_not_found')
      end

      # コピー先フォルダの取得
      folder = Doclibrary::Folder.find_by(id: folder_id)
      if folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_copy_folder_not_found')
      end

      # コピー元フォルダへの管理権限があるかをチェック
      unless src_folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      # コピー先フォルダへの管理権限があるかをチェック
      unless folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      # 現在の添付ファイル、画像ファイルの利用容量チェック
      if @title.is_disk_full_for_document_file? || @title.is_disk_full_for_graphic_file?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.has_exceeded_capacity')
      end

      begin
        Doclibrary::Doc.transaction do
          begin
            Doclibrary::File.transaction do
              begin
                # == ファイルコピー ==
                copy_file = Doclibrary::Doc.new
                copy_file.attributes = src_file.attributes
                # フォルダ情報変更
                unless is_folder_copy
                  copy_file.title = "#{copy_file.title} - " + I18n.t("rumi.doclibrary.file_folder_option.copy")
                end
                copy_file.category1_id = folder_id
                copy_file.id = nil
                # 作成日、更新日リセット
                copy_file.created_at = nil
                copy_file.updated_at = nil
                copy_file.latest_updated_at = Time.now
                # 作成者情報変更
                copy_file.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
                copy_file.creater_id = Core.user.code unless Core.user.code.blank?
                copy_file.creater = Core.user.name unless Core.user.name.blank?
                copy_file.createrdivision =
                    Core.user_group.name unless Core.user_group.name.blank?
                copy_file.createrdivision_id =
                    Core.user_group.code unless Core.user_group.code.blank?
                copy_file.creater_admin = (@gw_admin)? true : false
                # 更新者情報リセット
                copy_file.editdate = nil
                copy_file.editor = nil
                copy_file.editordivision = nil
                copy_file.editor_id = Core.user.code unless Core.user.code.blank?
                copy_file.editordivision_id =
                    Core.user_group.code unless Core.user_group.code.blank?
                copy_file.editor_admin = (@gw_admin)? true : false
                copy_file.save!

                # 添付ファイル情報コピー
                src_file.attach_files.each do |attach|
                  attributes = attach.attributes.reject do |key, value|
                    key == 'id' || key == 'parent_id'
                  end
                  attach_file = copy_file.attach_files.build(attributes)
                  attach_file.created_at = Time.now
                  attach_file.updated_at = Time.now

                  # 添付ファイルの存在チェック
                  unless File.exist?(attach.f_name)
                    raise I18n.t('rumi.doclibrary.drag_and_drop.message.attached_file_not_found')
                  end
                  upload = ActionDispatch::Http::UploadedFile.new({
                    :filename => attach.filename,
                    :content_type => attach.content_type,
                    :tempfile => File.open(attach.f_name)
                  })
                  attach_file._upload_file(upload)
                  attach_file.save!
                end

                # 承認者情報コピー
                src_file.recognizers.each do |recognizer|
                  attributes = recognizer.attributes.reject do |key, value|
                    key == 'id' || key == 'parent_id'
                  end
                  copy_file.recognizers.build(attributes).save!
                end
              end
            end
          rescue
            raise # エラーメッセージは上位メソッドで表示
          end
        end
      rescue
        raise # エラーメッセージは上位メソッドで表示
      end
    rescue => ex
      raise ex.message
    ensure
    end
  end

  # === フォルダ移動メソッド
  #  本メソッドは、フォルダを移動するメソッドである。
  # ==== 引数
  #  * src_folder_id: 移動対象フォルダID
  #  * dst_folder_id: 移動先フォルダID
  # ==== 戻り値
  #  なし
  def move_folder(src_folder_id, dst_folder_id)
    begin
      # 移動対象フォルダの取得
      src_folder = Doclibrary::Folder.find_by(id: src_folder_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_move_folder_not_found')
      end

      # 移動先フォルダの取得
      dst_folder = Doclibrary::Folder.find_by(id: dst_folder_id)
      if dst_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_move_folder_not_found')
      end

      # 階層上限を超える場合、移動させずエラー
      add_level = get_level_no(src_folder, 1, src_folder.level_no - 1)
      if (dst_folder.level_no + add_level) > Enisys::Config.application["doclibrary.level_no"].to_i
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.over_level_move')
      end

      # フォルダの移動先フォルダが現在のフォルダの場合、終了
      if src_folder.parent_id == dst_folder.id
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_movement')
      end

      # フォルダの移動先フォルダが移動対象フォルダの配下である場合、エラー
      if dst_folder.parent_tree.include?(src_folder)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.cannot_move_folder')
      end

      # == 移動対象全データ（フォルダ、ファイル、添付ファイル）のID取得（下位フォルダも含む） ==
      # 移動対象全フォルダ
      folder_ids = [src_folder.id]
      folder_ids = src_folder.get_child_folder_ids(folder_ids)

      # 移動対象全ファイル
      file_ids = []
      folder_ids.each do |folder_id|
        files = Doclibrary::Doc.where("category1_id = #{folder_id}")
        files.each do |file|
          file_ids << file.id
        end
      end

      # 移動対象全添付ファイル
      attach_file_ids = []
      file_ids.each do |file_id|
        attach_files = Doclibrary::File.where("parent_id = #{file_id}")
        attach_files.each do |attach_file|
          attach_file_ids << attach_file.id
        end
      end

      # フォルダ移動
      #
      # ※注意事項
      # 1)複数モデルデータを同時にロールバックさせるため、下記の条件をクリアすること
      #   ・テーブル毎にトランザクションを作成する
      #   ・処理中にDBコネクションを切り替えない（DBコネクションを変数化して使い回す）
      # 2)フォルダ、ファイル、添付ファイルを同時に更新するとlock状態になるため
      #   フォルダ → ファイル → 添付ファイルの順で更新を行う
      begin
        Doclibrary::Folder.transaction do
          begin
            Doclibrary::Doc.transaction do
              begin
                Doclibrary::File.transaction do
                  begin
                    # 移動フォルダについて権限チェックと情報変更
                    update_move_folder(
                        Doclibrary::Folder, src_folder_id, dst_folder_id, 1)

                    # 移動ファイルについて情報変更
                    unless file_ids.blank?
                      Doclibrary::Doc.where("id IN (#{file_ids.join(',')})")
                                        .update_all(:editdate => Time.now.strftime("%Y-%m-%d %H:%M"),
                                                    :editor => Core.user.name,
                                                    :editordivision => Core.user_group.name,
                                                    :editor_id => Core.user.code,
                                                    :editordivision_id => Core.user_group.code,
                                                    :editor_admin => (@gw_admin)? true : false,
                                                    :updated_at => Time.now,
                                                    :latest_updated_at => Time.now)
                    end

                    # 添付ファイルについて情報変更
                    unless attach_file_ids.blank?
                      Doclibrary::File.where("id IN (#{attach_file_ids.join(',')})")
                                         .update_all(:updated_at => Time.now)
                    end
                  end
                end
              rescue
                raise # エラーメッセージは上位メソッドで表示
              end
            end
          rescue
            raise # エラーメッセージは上位メソッドで表示
          end
        end
      rescue
        raise # エラーメッセージは上位メソッドで表示
      end
    rescue => ex
      raise ex.message
    ensure
    end
  end

  # === フォルダコピーメソッド
  #  本メソッドは、フォルダコピーするメソッドである。
  # ==== 引数
  #  * src_folder_id: コピー元フォルダID
  #  * dst_folder_id: コピー先フォルダID
  # ==== 戻り値
  #  なし
  def copy_folder(src_folder_id, dst_folder_id)
    begin
      # コピー元フォルダの取得
      src_folder = Doclibrary::Folder.find_by(id: src_folder_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_copy_folder_not_found')
      end

      # コピー先フォルダの取得
      dst_folder = Doclibrary::Folder.find_by(id: dst_folder_id)
      if dst_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_copy_folder_not_found')
      end

      # 階層上限を超える場合、移動させずエラー
      add_level = get_level_no(src_folder, 1, src_folder.level_no - 1)
      if (dst_folder.level_no + add_level) > Enisys::Config.application["doclibrary.level_no"].to_i
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.over_level_copy')
      end

      # フォルダのコピー先フォルダがコピー元フォルダの配下である場合、エラー
      if dst_folder.parent_tree.include?(src_folder)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.cannot_copy_folder')
      end

      # 現在の添付ファイル、画像ファイルの利用容量チェック
      if @title.is_disk_full_for_document_file? || @title.is_disk_full_for_graphic_file?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.has_exceeded_capacity')
      end

      # フォルダコピー
      create_copy_folder(src_folder_id, dst_folder_id)
    rescue => ex
      raise ex.message
    ensure
    end
  end

  # === 移動フォルダ更新メソッド
  #  本メソッドは、階層ごとに移動フォルダの情報を更新するメソッドである。
  #
  #   ※注意事項
  #   1)複数モデルデータを同時にロールバックさせるため、下記の条件をクリアすること
  #     ・テーブル毎にトランザクションを作成する
  #     ・処理中にDBコネクションを切り替えない（DBコネクションを変数化して使い回す）
  #   2)フォルダ、ファイル、添付ファイルを同時に更新するとlock状態になるため
  #     フォルダ情報のみ更新し、ファイル、添付ファイルについては後で更新する
  #
  # ==== 引数
  #  * doclibrary_folder_cnn: DBコネクション: DBコネクション（Doclibrary::Folder）
  #  * src_folder_id: 移動対象フォルダID
  #  * dst_folder_id: ドラッグ先フォルダID
  #  * folder_level: フォルダ階層
  # ==== 戻り値
  #  なし
  def update_move_folder(doclibrary_folder_cnn, src_folder_id, dst_folder_id, folder_level)
    begin
      # フォルダ移動のRollbackテスト用コード
      #raise 'フォルダ移動 Rollbackテスト' if folder_level==2

      # 移動対象フォルダの取得
      src_folder = doclibrary_folder_cnn.find_by(id: src_folder_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_move_folder_not_found')
      end

      # 移動先フォルダの取得
      dst_folder = doclibrary_folder_cnn.find_by(id: dst_folder_id)
      if dst_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_move_folder_not_found')
      end

      # 移動対象フォルダの親フォルダへの管理権限があるかをチェック
      unless src_folder.parent_folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      if folder_level == 1
        # 移動先フォルダへの管理権限があるかをチェック
        unless dst_folder.admin_user?(Core.user.id)
          raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
        end

        # 移動フォルダのトップフォルダについて情報変更
        src_folder.parent_id = dst_folder.id
        parent_folder = dst_folder
      else
        # 親フォルダの情報取得
        parent_folder = doclibrary_folder_cnn.find_by(id: src_folder.parent_id)
        raise if parent_folder.blank? # エラーメッセージは上位メソッドで表示
      end

      # フォルダ情報変更
      src_folder.docs_last_updated_at = Time.now
      src_folder.level_no = parent_folder.level_no + 1
      src_folder.save!

      # 下位フォルダについて権限チェックと情報変更
      src_folder.children.each do |child_folder|
        update_move_folder(
            doclibrary_folder_cnn, child_folder.id, dst_folder_id, folder_level + 1)
      end
    rescue => ex
      raise ex.message
    end
  end

  # === コピーフォルダ作成メソッド
  #  本メソッドは、階層ごとにコピーフォルダを作成するメソッドである。
  # ==== 引数
  #  * src_folder_id: コピー対象フォルダID
  #  * dst_folder_id: コピー先フォルダID
  # ==== 戻り値
  #  なし
  def create_copy_folder(src_folder_id, dst_folder_id)
    begin
      # コピー対象フォルダの取得
      src_folder = Doclibrary::Folder.find_by(id: src_folder_id)
      if src_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.src_copy_folder_not_found')
      end

      # コピー先フォルダの取得
      dst_folder = Doclibrary::Folder.find_by(id: dst_folder_id)
      if dst_folder.blank?
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.dst_copy_folder_not_found')
      end

      # コピー対象フォルダの親フォルダへの管理権限があるかをチェック
      unless src_folder.parent_folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      # コピー先フォルダへの管理権限があるかをチェック
      unless dst_folder.admin_user?(Core.user.id)
        raise I18n.t('rumi.doclibrary.drag_and_drop.message.no_authority_to_edit_folder')
      end

      new_folder = nil
      begin
        Doclibrary::Folder.transaction do
         # コピーフォルダを作成
          new_folder = Doclibrary::Folder.new
          new_folder.attributes = src_folder.attributes
          # 作成日、更新日リセット
          new_folder.id = nil
          new_folder.created_at = nil
          new_folder.updated_at = nil
          new_folder.docs_last_updated_at = Time.now
          # フォルダ情報変更
          new_folder.parent_id = dst_folder.id
          new_folder.level_no  = dst_folder.level_no + 1
          new_folder.save!
        end
      rescue
        raise # エラーメッセージは上位メソッドで表示
      end

      # コピーフォルダにコピー元フォルダ内ののファイルをコピー
      src_folder.child_docs.each do |child_file|
        copy_file(child_file.id, new_folder.id, true);
      end

      # 下位フォルダをコピー
      src_folder.children.each do |child_folder|
        create_copy_folder(child_folder.id, new_folder.id)
      end
    rescue => ex
      raise ex.message
    ensure
    end
  end

  def get_level_no(src_folder, level_no, base_level)
    level_no = src_folder.level_no - base_level if level_no < (src_folder.level_no - base_level)
    src_folder.children.each do |child|
      level_no = get_level_no(child, level_no, base_level)
    end
    return level_no
  end

private

  def item_params
    params.fetch(:item, {})
          .permit(:section_code, :category1_id, :title, :body, :category4_id, :_recognizers, :_recognition,
                  :state, :edit_start)
  end


end

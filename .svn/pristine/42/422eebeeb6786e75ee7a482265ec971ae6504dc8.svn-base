module Doclibrary::Admin::DocsHelper

  def new_doclib_category_qstring()
    return "&cat=#{params[:cat]}"
  end

  def folder_doclib_category_qstring(item)
    ret = "?title_id=#{item.title_id}"
    ret += "&state=#{params[:state]}"
    ret += "&gcd=#{item.code}" if params[:state] == 'GROUP'
    ret += "&cat=#{item.id}" unless params[:state] == 'GROUP'
    ret += "#{ret}&limit=#{params[:limit]}" unless params[:limit].blank?
    return ret
  end

  def doclib_uri_params
    state = params[:state]
    base_path = "&state=#{state}"
    if state=='GROUP'
      ret = base_path+"&grp=#{params[:grp]}&gcd=#{params[:gcd]}"
    else
      ret = base_path+"&cat=#{params[:cat]}"
    end
    return ret
  end

  def doclibrary_show_uri(item,prms=nil)
    if prms.blank?
      state = 'CATEGORY'
    else
      state = prms[:state]
    end
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}&cat=#{prms[:cat]}&gcd=#{prms[:gcd]}" if state == 'GROUP'
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}&cat=#{prms[:cat]}&gcd=#{prms[:gcd]}" if state == 'DATE'
    ret = "#{doclibrary_docs_path}/#{item.id}/?title_id=#{item.title_id}&gcd=#{prms[:gcd]}" unless state == 'GROUP' unless state == 'DATE'
    return ret
  end

  def get_piece_banners
    piece_initialize
    @title = Doclibrary::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    unless params[:piece_param].blank?
      admin_flags(params[:title_id])
    end
  end

  def get_piece_menus
    piece_initialize
    get_role_index

    #if params[:state] == 'GROUP'
      make_hash_variable_doc_counts2
    #else
      index_category
    #end

    @piece_group_names = Array.new
    for grp_item in @piece_grp_items
      str_count = ''
      str_count = "(#{@group_doc_counts[grp_item.code].total_cnt.to_s})" unless @group_doc_counts[grp_item.code].blank?
      group_name = "#{grp_item.name}"
      unless str_count.blank?
        @piece_group_names << [group_name, grp_item.code ]
      end
    end
  end

  def piece_initialize
    params[:state] = @title.default_folder.to_s if params[:state].blank?
    unless params[:state] == 'GROUP'
      folder = Doclibrary::Folder
      @folder_items = folder.where(title_id: @title.id).order("level_no DESC, sort_no DESC, id DESC")
    end
    @piece_grp_items = System::Group.without_root.without_disable
  end

  def index_category
    return false if params[:state] == 'GROUP'

    folder = Doclibrary::ViewAclFolder
    @piece_items = folder.where(title_id: @title.id).where("parent_id IS NULL").order("level_no, sort_no, id")
    fid = params[:cat]
    set_folder_array(fid)
  end

  def set_folder_array(param)
    @folders = []
    return if param.blank?
    fid = param.to_s
    @folder_items.each do |item|
      if fid.to_s == item.id.to_s
        @folders[item.level_no] = item.id
        fid = item.parent_id.to_s
      end if item.state == 'public'
    end
  end

  def make_hash_variable_doc_counts2
    user_groups_code = Core.user.user_group_parent_codes.join(",")

    str_where  = " (state = 'public' AND doclibrary_folders.title_id = #{@title.id}) AND ((acl_flag = 0)"
    if @doclibrary_admin
      str_where  += " OR (acl_flag = 9))"
    else
      str_where  += " OR (acl_flag = 1 AND acl_section_code IN (#{user_groups_code}))" unless user_groups_code.blank?
      unless (params[:state] == 'DRAFT' || params[:state] == 'RECOGNIZE' || params[:state] == 'PUBLISH')
        str_where  += " OR (acl_flag = 1 AND acl_section_id = 0)"
      end
      str_where  += " OR (acl_flag = 2 AND acl_user_id = '#{Core.user.id}'))"
    end

    str_sql = 'SELECT doclibrary_folders.id FROM doclibrary_folder_acls, doclibrary_folders'
    str_sql += ' WHERE doclibrary_folder_acls.folder_id = doclibrary_folders.id'
    str_sql += ' AND ( ' + str_where + ' )'
    str_sql += ' GROUP BY doclibrary_folders.id'

    cnn_view_acl_folders = Doclibrary::ViewAclFolder
    view_acl_folders = cnn_view_acl_folders.find_by_sql(str_sql)
    folder_ids = view_acl_folders.map{|f| f.id}.join(",")

    @group_doc_counts = []
    
    doc_state = "'public'"
    case params[:state]
    when 'DRAFT'
      doc_state = "'draft'"
    when 'RECOGNIZE'
      doc_state = "'recognize'"
    when 'PUBLISH'
      doc_state = "'recognized'"
    end

    unless folder_ids.blank?
      str_sql = "SELECT section_code, COUNT(id) AS total_cnt FROM doclibrary_docs"
      str_sql += " WHERE category1_id IN (#{folder_ids}) AND state = " + doc_state
      if params[:state] == 'DRAFT'
        str_sql += " AND section_code IN (#{user_groups_code})" unless user_groups_code.blank? unless @doclibrary_admin
      end
      str_sql += " GROUP BY section_code"

      cnn_docs = Doclibrary::Doc
      docs = cnn_docs.find_by_sql(str_sql)
      @group_doc_counts = docs.index_by(&:section_code)
    end
  end
end

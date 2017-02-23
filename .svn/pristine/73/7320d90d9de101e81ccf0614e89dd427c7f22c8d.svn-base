# encoding: utf-8
module Gwbbs::Admin::DocsHelper

  def is_comment_delete(section_code, editor_id, is_admin)
    ret = false
    ret = true if is_admin
    ret = true if section_code == Core.user_group.code
    ret = true if editor_id == Core.user.code
    return ret
  end

  def admin_doc_size_usage_rate
    body_size_capacity = 0
    body_size_currently = 0
    body_size_capacity = @item.doc_body_size_capacity unless @item.doc_body_size_capacity.blank?
    body_size_currently = @item.doc_body_size_currently unless @item.doc_body_size_currently.blank?
    msg = ""
    return msg if body_size_capacity == 0
    return msg if body_size_currently == 0
    usage = 0
    usage = body_size_currently.to_f / body_size_capacity.megabytes.to_f unless body_size_capacity.megabytes.to_f == 0
    usage = usage * 100
    msg = t("rumi.gwbbs.message.use_body_size") + " #{body_size_currently}" + t("rumi.gwbbs.message.byte") + t("rumi.gwbbs.message.tail_message") if usage < 1
    msg = t("rumi.gwbbs.message.use_body_capacity") + " #{sprintf('%.04g', usage)}%" + t("rumi.gwbbs.message.tail_message")  if 1 <= usage
    limit_message1 = t("rumi.gwbbs.message.use_body_limit_near")
    limit_message2 = t("rumi.gwbbs.message.use_body_limit_over")
    msg = required(" ※#{msg} #{limit_message1}") if 90 < usage if usage <= 99.9999
    msg = required(" ※#{msg} #{limit_message2}") if 100 <= usage
    return msg
  end

  def open_gwbbs_form(uri)
    uri = escape_javascript(uri)
    "openGwbbsForm('#{uri}', '#{gwbbs_form_style}');"
  end

  def gwbbs_form_style
    "resizable=yes,scrollbars=yes"
  end

    def open_gwcircular_form(uri)
    uri = escape_javascript(uri)
    "openGwcircularForm('#{uri}', '#{gwcircular_form_style}');"
  end

  def gwcircular_form_style
    "resizable=yes,scrollbars=yes"
  end

  def get_piece_menus
    params[:state] = 'DATE' if params[:state].blank?
    @piece_base_item = Gwbbs::Doc
    normal_index(false)
    flg_exception = false
    flg_exception = true if @title.form_name == 'form006'
    flg_exception = true if @title.form_name == 'form007'
    if flg_exception
      @piece_groups  = @title.notes_field01
      group_index_form007
      get_categories
      category_index
      monthlies_index_form007 if @title.form_name == 'form006'
      monthlies_index if @title.form_name == 'form007'
    else
      @piece_groups = System::Group.without_root.without_disable
      make_hash_group_doc_counts
      get_categories
      piece_category_index
      monthlies_index
    end

    @piece_group_names = Array.new
    for grp_item in @piece_groups
      str_count = ''
      str_count = "(#{@piece_group_doc_counts[grp_item.code].cnt.to_s})" unless @piece_group_doc_counts[grp_item.code].blank?
      group_name = "#{grp_item.name}"
      unless str_count.blank?
        @piece_group_names << [group_name, grp_item.code ]
      end
    end
  end

  def make_hash_group_doc_counts
    user_groups_code = Core.user.user_group_parent_codes.join(",")
    str_sql  = "SELECT section_code, count(id) as cnt"
    str_sql += " FROM gwbbs_docs WHERE title_id = #{@title.id}"
    case params[:state]
    when "DRAFT"
      str_sql += " AND state = 'draft'"
      str_sql += " AND section_code in (#{user_groups_code})" unless @gw_admin
    when "NEVER"
      str_sql += " AND state = 'public' AND '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' < able_date"
      str_sql += " AND section_code in (#{user_groups_code})" unless @gw_admin
    when "VOID"
      str_sql += " AND state = 'public' AND expiry_date < '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00'"
      str_sql += " AND section_code in (#{user_groups_code})" unless @gw_admin
    else
      str_sql += " AND state = 'public'"
      str_sql += " AND '#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date"
    end
    
    str_sql += ' GROUP BY section_code'
    item = Gwbbs::Doc
    @piece_group_doc_counts = item.find_by_sql(str_sql).index_by(&:section_code)
  end

  def get_categories
    @piece_categories1 = []
  end

  def piece_category_index
    item = @piece_base_item.where(title_id: @title.id, state: 'public')
                     .where("'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date")
    @cats = item.select("category1_id, count(id) as cnt").group("category1_id").order("category1_id")
  end

  def monthlies_index
    item = @piece_base_item.where(title_id: @title.id, state: 'public')
                           .where("'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date")
    @piece_monthlies = item.select("DATE_FORMAT(latest_updated_at,'%Y年%m月') AS month ,DATE_FORMAT(latest_updated_at,'%Y') AS yy,DATE_FORMAT(latest_updated_at,'%m') AS mm ,count(id) as cnt")
                     .group("DATE_FORMAT(latest_updated_at,'%Y年%m月')")
                     .order("DATE_FORMAT(latest_updated_at,'%Y年%m月') DESC")
  end

  def group_index_form007
    item = @piece_base_item.where(title_id: @title.id, state: 'public')
                           .where("'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date")
    @piece_grp_items = item.select("inpfld_002, count(id) as cnt").group("inpfld_002").order("inpfld_002")
  end

  def monthlies_index_form007
    item = @piece_base_item.where(title_id: @title.id, state: 'public')
                           .where("'#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date")
    @piece_monthlies = item.select("inpfld_006w,count(id) as cnt")
                           .group("inpfld_006w")
                           .order("DATE_FORMAT(inpfld_006d,'%Y年%m月') DESC")
  end
end
module Doclibrary::Controller::AdmsInclude

  def normal_index(pagenation_flag)
    @items = Doclibrary::Doc.where(title_id: params[:title_id])
                            .where(gwboard_select_status(params))
                            .where(Doclibrary::Doc.get_keywords_condition(params[:kwd], :title, :body).where)
                            .order(gwboard_sort_key(params))
                            .paginate(page: params[:page]).limit(params[:limit])
  end

  def all_index

    # ログインユーザーの所属グループコードを取得（親グループを含む）
    user_group_parent_codes = []
    Core.user.enable_user_groups.each do |user_group|
      user_group_parent_codes += user_group.group.parent_tree.map(&:code)
    end
    user_group_parent_codes.uniq!


    sql = Condition.new

    sql.or do |d2|
      d2.and "sql", "state != 'public'"
      d2.and "sql", "state != 'preparation'"
      d2.and :title_id, params[:title_id]
      d2.and :editor_id, Core.user.code
    end
    sql.or do |d2|
      d2.and "sql", "state != 'public'"
      d2.and "sql", "state != 'preparation'"
      d2.and :title_id, params[:title_id]
      d2.and :editor_admin, 0
      d2.and :editordivision_id, user_group_parent_codes
    end
    sql.or do |d2|
      d2.and "sql", "state = 'public'"
      d2.and :title_id, params[:title_id]
    end

    @items = Doclibrary::Doc.where(sql.where).order('latest_updated_at DESC')
                            .paginate(page: params[:page]).limit(params[:limit])

  end

  def all_index_admin
    @items = Doclibrary::Doc.where("state != 'preparation'")
                            .where(title_id: params[:title_id])
                            .where(Doclibrary::Doc.get_keywords_condition(params[:kwd], :title, :body).where)
                            .order('latest_updated_at DESC')
                            .paginate(page: params[:page]).limit(params[:limit])
  end

  def recognize_index
    sql = Condition.new
    sql.and "sql", "doclibrary_recognizers.recognized_at Is Null"
    sql.and "sql", "doclibrary_recognizers.code = '#{Core.user.code}'"
    sql.and "sql", "doclibrary_docs.state = 'recognize'"

    join = "INNER JOIN doclibrary_recognizers ON doclibrary_docs.id = doclibrary_recognizers.parent_id AND doclibrary_docs.title_id = doclibrary_recognizers.title_id"

    @items = Doclibrary::Doc.joins(join).where(sql.where).paginate(page: params[:page]).limit(params[:limit])
  end

  def recognized_index
    c1 = Condition.new
    c1.and "sql", gwboard_select_status(params)
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Core.user.code

    @items = Doclibrary::Doc.where(c1.where).order(gwboard_sort_key(params)).paginate(page: params[:page]).limit(params[:limit])
  end

  def recognized_index_admin
    @items = Doclibrary::Doc.where(title_id: params[:title_id])
                            .where(gwboard_select_status(params))
                            .where(Doclibrary::Doc.get_keywords_condition(params[:kwd], :title, :body).where)
                            .order(gwboard_sort_key(params))
                            .paginate(page: params[:page]).limit(params[:limit])
  end
end
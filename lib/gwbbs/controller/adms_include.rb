module Gwbbs::Controller::AdmsInclude

  def normal_index(pagenation_flag)
    #item = item.new
    #item.and :title_id, params[:title_id]
    #item.and "sql", gwbbs_select_status(params)
    item = Gwbbs::Doc.where(title_id: params[:title_id]).where(gwbbs_select_status(params))
    item = item.where(item.search(params)).order(gwboard_sort_key(params))
    #item.order  gwboard_sort_key(params)
    #if pagenation_flag
    @items = item.paginate(page: params[:page]).limit(params[:limit])
    #end
    #item.page   params[:page], params[:limit] if pagenation_flag
    #@items = item.find(:all
    #@items = item.all
  end

  def all_index

    c1 = Condition.new
    c1.and "sql", "state != 'public'"
    c1.and "sql", "state != 'preparation'"
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Core.user.code

    c2 = Condition.new
    c1.and "sql", "state != 'public'"
    c2.and "sql", "state != 'preparation'"
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Core.user_group.code

    c3 = Condition.new
    c3.and "sql", "state = 'public'"
    c3.and :title_id, params[:title_id]

    item = Gwbbs::Doc.new
    item.or c1
    item.or c2
    item.or c3
    item.order  'latest_updated_at DESC'
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognized_index

    c1 = Condition.new
    c1.and "sql", gwbbs_select_status(params)
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Core.user.code

    c2 = Condition.new
    c2.and "sql", gwbbs_select_status(params)
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Core.user_group.code

    item = Gwbbs::Doc.new
    item.or c1
    item.or c2
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def all_index_admin
    @items = Gwbbs::Doc.where("state != 'preparation'")
                       .where(title_id: params[:title_id])
                       .search(params)
                       .order('latest_updated_at DESC')
                       .paginate(page: params[:page]).limit(params[:limit])
  end

  def recognized_index_admin
    @items = Gwbbs::Doc.where(title_id: params[:title_id])
                     .where(gwbbs_select_status(params))
                     .search(params)
                     .order(gwboard_sort_key(params))
                     .paginate(page: params[:page]).limit(params[:limit])
  end

  def recognize_index
    sql = Condition.new
    sql.and "sql", "gwbbs_recognizers.recognized_at Is Null"
    sql.and "sql", "gwbbs_recognizers.code = '#{Core.user.code}'"
    sql.and "sql", "gwbbs_docs.state = 'recognize'"

    join = "INNER JOIN gwbbs_recognizers ON gwbbs_docs.id = gwbbs_recognizers.parent_id AND gwbbs_docs.title_id = gwbbs_recognizers.title_id"

    @items = Gwbbs::Doc.joins(join).where(sql.where).paginate(page: params[:page]).limit(params[:limit])
  end

end
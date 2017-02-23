# encoding: utf-8
class Gwsub

  def self.modelize(table_name)
    name = table_name.singularize
    name1 = name.split('_')
    name2 = name1.collect{|x| x.capitalize}
    name3 = []
    name2.each_with_index do |name,idx|
      if idx == 0
      else
        name3 << name
      end
    end
    name4 = name3.join('')
    name5 = name2[0]+'::'+name4
    return name5
  end

  def self.grouplist4(fyear_id=nil, all = nil, role = true ,top = nil ,parent_id=nil, options = {})
    # 所属選択DD用ツリー
    # fyear_id 対象年度id
    # all   選択リストに'すべて'を含む指定   'all':含む
    # role : 権限
    # top : true の時は、level_no =1 から表示
    # parent_id : 指定があれば、上位部署で絞る
    # options[:return_pattern] : オプション。返り値の設定。空欄、もしくは0なら従来のセレクトボックス用文字列を返す。2010/07/30追加。松木。
    #  1：groupの実体も同時に返す
    #  2：parent_idも同時に返す
    # options[:checkup] : true 健康診断申込からの要求で、教育委員会（level2 code 500）を除外
    # options[:code] : 'none' 所属選択リストで、所属コードをつけないパターン
    # options[:fyear] : true fyear_idを使用する。デフォルトは今日の日付
    # options[:kouann] : true 公安委員会表示許可
    # options[:through_state] : true stateを見ない　//政策評価用
    # options[:show_ids] : 1,2,3.. カンマ区切りで取得するID指定　//政策評価用(公安委員会用)

    # 年度指定が無ければ、今日を含む年度
    if fyear_id.to_i==0
      fyear_target = Gw::YearFiscalJp.get_record(Time.now)
      if fyear_target.blank?
        fyear_target_id = Gw::YearFiscalJp.order("fyear DESC , start_at DESC").first.id
      else
        fyear_target_id = fyear_target.id
      end
    else
      fyear_target_id = fyear_id
    end
    #年度開始日取得
      fyear = Gw::YearFiscalJp.find(fyear_target_id)
      start_at_fyear  = fyear.start_at
      end_at_fyear  = fyear.end_at
    # 管理者権限がなければ、自所属のみ表示
    if role != true
      grp = Core.user_group
      group_select = []
      if options.has_key?(:code) and options[:code] == 'none'
        group_select << [grp.name,grp.id]
      else
        group_select << ['('+grp.code+')'+grp.name,grp.id]
      end
      return group_select
    end

    current_time = Time.now
    current_time = end_at_fyear if options.has_key?(:fyear) and options[:fyear] == true

    #状態での絞り込み無し
    if options[:through_state]
      state_cond = ""
    else
      state_cond = "state='enabled' and "
    end

    # 親指定があれば、level2は指定のid
    group_cond = "#{state_cond} level_no=2"

    group_cond += " and id=#{parent_id}"  unless parent_id.to_i==0
    if options.has_key?(:fyear) and options[:fyear] == true
      # 開始日・終了日を指定年度の日時で判定
      group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{start_at_fyear.strftime("%Y-%m-%d 23:59:59")}' ) "
    else
      # 開始日・終了日を現在日時で判定
      # 開始日が過去日時
      group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      # 終了日が将来日時
      group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    end

    group_order   = "code , sort_no , start_at DESC, end_at IS Null ,end_at DESC"
    group_parents = System::Group.where(group_cond).order(group_order)
    # 選択DD　作成
    group_select = []
    if group_parents.blank?
      group_select << ["所属未設定",0]
      return group_select
    end
    # all option
    group_select << ["すべて",0]  if all == 'all'
    # level_no = 1
    if top == true
      top_g  = System::Group.find(1)
      if options.has_key?(:code) and options[:code] == 'none'
        group_select << [top_g.name,top_g.id]
      else
        group_select << ['('+top_g.code+')'+top_g.name,top_g.id]
      end
    end
    # level_no = 2 で繰返し
    for group in group_parents

      if options[:through_state]
        child_cond    = "level_no=3 and parent_id=#{group.id}"
      else
        child_cond    = "state='enabled' and level_no=3 and parent_id=#{group.id}"
      end

      if options.has_key?(:fyear) and options[:fyear] == true
        # 開始日・終了日を指定年度の日時で判定
        # ID指定有
        if options.has_key?(:show_ids)
          child_cond   << " and (start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}' or id IN (#{options[:show_ids]}) )"
        else
          child_cond   << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
        end
      else
        # 開始日・終了日を現在日時で判定
        # 開始日が過去日時
        child_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
      end
      child_order   = "code , sort_no , start_at DESC, end_at IS Null ,end_at DESC"
      children = System::Group.where(child_cond).order(child_order)
      unless children.blank?
        # level_no = 3
        children.each_with_index do |child , i|
          # level_no = 2 を設定　（level2はlevel3筆頭課のidを設定）
          if i == 0 and options.has_key?(:code) and options[:code] == 'none'
            group_select  << ["#{group.name}", group.id]
          else
#            group_select << ["(#{group.code})#{group.name}" , child.id] if i == 0 && (options[:return_pattern].blank? || options[:return_pattern] == 0)
#            group_select << ["(#{group.code})#{group.name}", child.id, group ] if i == 0 && options[:return_pattern] == 1
#            group_select  << ["(#{group.code})#{group.name}", group.id] if i == 0 && options[:return_pattern] == 2
            group_select << ["#{group.name}" , child.id] if i == 0 && (options[:return_pattern].blank? || options[:return_pattern] == 0)
            group_select << ["#{group.name}", child.id, group ] if i == 0 && options[:return_pattern] == 1
            group_select  << ["#{group.name}", group.id] if i == 0 && options[:return_pattern] == 2
          end
          # level_no = 3 を設定
          if options.has_key?(:code) and options[:code] == 'none'
            group_select << ["　　 - #{child.name}" , child.id]
          else
#            group_select << ["　　 - (#{child.code})#{child.name}", child.id] if options[:return_pattern].blank? || options[:return_pattern] == 0
#            group_select << ["　　 - (#{child.code})#{child.name}", child.id, child] if options[:return_pattern] == 1
#            group_select << ["　　 - (#{child.code})#{child.name}", child.id] if options[:return_pattern] == 2
            group_select << ["　　 - #{child.name}", child.id] if options[:return_pattern].blank? || options[:return_pattern] == 0
            group_select << ["　　 - #{child.name}", child.id, child] if options[:return_pattern] == 1
            group_select << ["　　 - #{child.name}", child.id] if options[:return_pattern] == 2
            group_select << [child.name, "child_group_#{child.id}"] if options[:return_pattern] == 3 # スケジュール登録画面での所属検索用
            group_select << [child.name, "#{child.id}"] if options[:return_pattern] == 4 # スケジュール登録画面での所属検索用
          end
        end
      end
    end
    return group_select
  end

end

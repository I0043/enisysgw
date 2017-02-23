module Doclibrary::Model::DbnameAlias

  def admin_flags(title_id)
    @doclibrary_admin = @gw_admin
    unless @doclibrary_admin
      items = Doclibrary::Adm.where(user_id: 0, group_id: Core.user.user_group_parent_ids)
      items = items.where(title_id: title_id) unless title_id == '_menu'
      @doclibrary_admin = true unless items.blank?

      unless @doclibrary_admin
        items = Doclibrary::Adm.where(user_id: Core.user.id)
        items = items.where(title_id: title_id) unless title_id == '_menu'
        @doclibrary_admin = true unless items.blank?
      end
    end
  end

  # === フォルダの管理権限判定メソッド
  #  ファイル管理の全フォルダのうち、いずれかのフォルダに管理権限があるか判定するメソッドである。
  #  判定結果は@has_some_folder_adminに保存する。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def set_has_some_folder_admin_flag
    @has_some_folder_admin = false
    if @gw_admin || @doclibrary_admin
      # ファイル管理の管理権限がある場合は、フォルダの管理権限もあり
      @has_some_folder_admin = true
      return
    end

    # フォルダの管理権限チェック
    unless @has_some_folder_admin

      condition = "(admins_json IS NOT NULL AND admins_json != '[]') OR " +
                  "(admin_groups_json IS NOT NULL AND admin_groups_json != '[]') "
      roles = Doclibrary::Folder.where(title_id: @title.id)
                                .where(condition)

      roles.each do |role|
        admin_groups = JsonParser.new.parse(role.admin_groups_json)
        admins = JsonParser.new.parse(role.admins_json)

        # ログインユーザーがグループ管理権限に含まれるか？
        #user_group_ids = Core.user.groups.map(&:id)
        user_group_ids = Core.user.user_group_parent_ids
        admin_groups.each do |group|
          if user_group_ids.include?(group[1].to_i)
            @has_some_folder_admin = true
            return
          end
        end
        # ログインユーザーが個人管理権限に含まれるか？
        admins_ids = admins.map{|admin| admin[1].to_i}
        if admins_ids.include?(Core.user.id)
          @has_some_folder_admin = true
          return
        end
      end
    end
  end

  def get_readable_flag
    @is_readable = @gw_admin || @doclibrary_admin
    unless @is_readable
      users_groups = System::UsersGroup.where(user_id: Core.user.id).where("end_at is null")
      groups = System::Group.where(id: users_groups.map(&:group_id))
      group_ids = []
      group_ids << 0
      groups.each do |group|
        group_ids << group.id
        group_ids << group.parent_id
      end
      g_read = Doclibrary::Role.where(title_id: @title.id, role_code: "r", group_id: group_ids)
      @is_readable = true if g_read.present?
      
      u_read = Doclibrary::Role.where(title_id: @title.id, role_code: "r", user_id: Core.user.id)
      @is_readable = true if u_read.present?
    end
  end

  def doclib_db_alias(item)

    title_id = params[:title_id]
    title_id = @title.id unless @title.blank?

    cnn = item.establish_connection

    cn = cnn.spec.config[:database]

    dbname = ''
    dbname = @title.dbname unless @title.blank?

    unless dbname == ''
      cnn.spec.config[:database] = dbname.to_s
    else
      l = 0
      l = cn.length if cn
      if l != 0
        i = cn.rindex "_", cn.length
        cnn.spec.config[:database] = cn[0,i] + '_doc'
      else
        cnn.spec.config[:database] = "dev_jgw_doc"
      end

      unless title_id.blank?
        if is_integer(title_id)
          cnn.spec.config[:database] +=  '_' + sprintf("%06d", title_id)
        end
      end
    end
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item

  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

end

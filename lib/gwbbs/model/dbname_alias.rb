# -*- encoding: utf-8 -*-
module Gwbbs::Model::DbnameAlias
  def get_writable_flag
    @is_writable = true if @gw_admin
    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwbbs::Role.order('group_code').where(sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'
        for user_group in Core.user.enable_user_groups
          @is_writable = true if item.group_code == user_group.group_code
          @is_writable = true if item.group_code == user_group.group.parent.code unless user_group.group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end

    unless @is_writable
      item = Gwbbs::Role.where(role_code: 'w', title_id: @title.id, user_code: Core.user.code).first
      @is_writable = true if item.user_code == Core.user.code unless item.blank?
    end
  end

  def get_readable_flag
    @is_readable = true if @gw_admin
    unless @is_readable
      sql = Condition.new
      sql.and :role_code, 'r'
      sql.and :title_id, @title.id
      sql.and 'sql', 'user_id IS NULL'
      items = Gwbbs::Role.order('group_code').where(sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'
        for user_group in Core.user.enable_user_groups
          @is_readable = true if item.group_code == user_group.group_code
          @is_readable = true if item.group_code == user_group.group.parent.code unless user_group.group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end

    unless @is_readable
      item = Gwbbs::Role.where(role_code: 'r', title_id: @title.id, user_code: Core.user.code).first
      @is_readable = true if item.user_code == Core.user.code unless item.blank?
    end
  end

  def gwbbs_db_alias(item)
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
        cnn.spec.config[:database] = cn[0,i] + '_bbs'
      else
        cnn.spec.config[:database] = "dev_jgw_bbs"
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

  def clone_doc(item, options = {})
    #複製時も公開開始日を5分刻みにする
    now = Time.now
    hour = now.hour # 時間
    if now.min > 55 && hour <= 22 # 時間繰り上がり用
      hour = hour + 1
    end
    if now.min > 55
      min = 0
    else
      divmod = now.min.divmod(5)
      if divmod[1] > 0 # 分（5分刻み用）
        min = (divmod[0] + 1) * 5
      else
        min = now.min
      end
    end
    _wrk_st = Time.local(now.year, now.month, now.day, hour, min, 0)
    d_load_st = Gw.datetime_str(_wrk_st)

    _clone = item.class.new
    _clone.attributes = item.attributes
    _clone.id = nil
    _clone.unid = nil
    _clone.created_at = nil
    _clone.updated_at = nil
    _clone.recognized_at = nil
    _clone.published_at = nil
    _clone.state = 'draft'
    _clone.category4_id = 0
    _clone.name = nil
    _clone.latest_updated_at = Core.now
    _clone.createdate = nil
    _clone.creater_admin = nil
    _clone.createrdivision_id = nil
    _clone.createrdivision = nil
    _clone.creater_id = nil
    _clone.creater = nil
    _clone.editdate = nil
    _clone.editor_admin = nil
    _clone.editordivision_id = nil
    _clone.editordivision = nil
    _clone.editor_id = nil
    _clone.editor = nil
    _clone.able_date = d_load_st
    _clone.expiry_date = "#{@title.default_published.months.since.strftime("%Y-%m-%d")} 23:59:59"
    _clone.section_code = Core.user_group.code

    group = Gwboard::Group.where(code: _clone.section_code, state: 'enabled').first
    _clone.section_name = group.name if group

    @before_state = item.state
    _clone.creater_admin = true
    _clone.editor_admin = false
    mode = ''
    mode = 'create' if _clone.createdate.blank?
    if @before_state == 'draft'
      mode = 'create'
    end if _clone.editdate.blank?
    if mode == 'create'
      _clone.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.creater_id = Core.user.code unless Core.user.code.blank?
      _clone.creater = Core.user.name unless Core.user.name.blank?
      _clone.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
      _clone.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.editor_id = Core.user.code unless Core.user.code.blank?
      _clone.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.creater_admin = @gw_admin
      _clone.editor_admin = @gw_admin
      _clone.name_creater_section_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.name_creater_section = Core.user_group.name unless Core.user_group.name.blank?
    else
      _clone.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.editor = Core.user.name unless Core.user.name.blank?
      _clone.editordivision = Core.user_group.name unless Core.user_group.name.blank?
      _clone.editor_id = Core.user.code unless Core.user.code.blank?
      _clone.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.editor_admin = @gw_admin
    end

    respond_to do |format|
      if _clone.save
        @doc_body = _clone.body
        copy_attached_files(item, _clone)
        unless @doc_body == _clone.body
          _clone.body = @doc_body
          _clone.save
        end
        params[:state] = 'DRAFT'
        location = _clone.edit_path + gwbbs_params_set
        format.html { redirect_to location }
      else
        flash.now[:notice] = I18n.t("rumi.message.notice.copy_fail")
        location = item.show_path + gwbbs_params_set
        format.html { redirect_to location }
      end
    end
  end

  def copy_attached_files(item, clone)
    files = Gwbbs::File.where(title_id: item.title_id, parent_id: item.id).order('id')
    for file in files
     _clone = file.class.new
     _clone.attributes = file.attributes
     _clone.id = nil
     _clone.parent_id = clone.id
     _clone.db_file_id = -1
     _clone.save
     begin
       FileUtils.mkdir_p(_clone.f_path) unless FileTest.exist?(_clone.f_path)
       FileUtils.cp(file.f_name, _clone.f_name)
       @doc_body = @doc_body.gsub(file.file_uri('gwbbs'), _clone.file_uri('gwbbs'))
     rescue
     end
    end

    f_item = Gwbbs::File
    total = f_item.where('unid = 1').sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = f_item.where('unid = 2').sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save

  end

  def is_integer(no)
    chg = no.to_s
    return chg.to_i
  end
end

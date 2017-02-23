#encoding:utf-8
module Gwcircular::Model::DbnameAlias

  def gwcircular_select_status(params)
    str = ''
    case params[:cond]
    when "admin"
      str = "able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    when "void"
      str = "expiry_date < '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    else
      str = "able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    end

    unless params[:mm].blank?
      from_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, 1)
      to_date = Date.new(params[:yyyy].to_i, params[:mm].to_i, -1)
      str += " AND created_at between '#{from_date.strftime("%Y/%m/%d")} 00:00:00' and '#{to_date.strftime("%Y/%m/%d")} 23:59:59'" if from_date if to_date
    end unless params[:yyyy].blank?

    unless params[:grp].blank?
      createrdivision = params[:grp]
      str += " AND createrdivision_id like '#{createrdivision}'"
    end
    return str
  end

  def get_writable_flag
    @is_writable = @gw_admin

    unless @is_writable
      sql = Condition.new
      sql.and :role_code, 'w'
      sql.and :title_id, @title.id
      items = Gwcircular::Role.order('group_code').where(sql.where)
      items.each do |item|
        @is_writable = true if item.group_code == '0'

        for group in Core.user.groups
          @is_writable = true if item.group_code == group.code
          @is_writable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_writable
        end
        break if @is_writable
      end
    end

    unless @is_writable
      item = Gwcircular::Role.where(role_code: 'w', title_id: @title.id, user_code: Core.user.code).first

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
      items = Gwcircular::Role.order('group_code').where(sql.where)
      items.each do |item|
        @is_readable = true if item.group_code == '0'

        for group in Core.user.groups
          @is_readable = true if item.group_code == group.code
          @is_readable = true if item.group_code == group.parent.code unless group.parent.blank?
          break if @is_readable
        end
        break if @is_readable
      end
    end

    unless @is_readable
      item = Gwcircular::Role.where(role_code: 'r', title_id: @title.id, user_code: Core.user.code).first

      @is_readable = true if item.user_code == Core.user.code unless item.blank?
    end
  end

  def get_readable_doc_flag(show_item)
    return unless @is_readable unless @gw_admin

    sql = Condition.new
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :doc_type , 0
      d.and :id , show_item.parent_id
      d.and :target_user_code , Core.user.code
    }
    sql.or {|d|
      d.and :title_id , @title.id
      d.and :doc_type , 1
      d.and :parent_id , show_item.parent_id
      d.and :state ,'!=', 'preparation'
      d.and :target_user_code , Core.user.code
    }
    item = Gwcircular::Doc.new
    items = item.where(sql.where).select(:id)
    @is_readable = false if items.count == 0
  end

  def clone_doc(item, options = {})
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
    _clone.able_date = Time.now.strftime("%Y-%m-%d")
    _clone.expiry_date = @title.default_published.months.since.strftime("%Y-%m-%d")

    _clone.section_code = Core.user_group.code

    group = Gwboard::Group.where(code: _clone.section_code, state: 'enabled').first
    _clone.section_name = group.code + group.name if group

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
      _clone.creater_admin = true if @gw_admin
      _clone.creater_admin = false unless @gw_admin
      _clone.editor_admin = true if @gw_admin          #1
      _clone.editor_admin = false unless @gw_admin     #0
    else
      _clone.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
      _clone.editor = Core.user.name unless Core.user.name.blank?
      _clone.editordivision = Core.user_group.name unless Core.user_group.name.blank?
      _clone.editor_id = Core.user.code unless Core.user.code.blank?
      _clone.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      _clone.editor_admin = true if @gw_admin          #1
      _clone.editor_admin = false unless @gw_admin     #0
    end

    respond_to do |format|
      if _clone.save
        @doc_body = _clone.body
        copy_attached_files(item, _clone)
        unless @doc_body == _clone.body
          _clone.body = @doc_body
          _clone.save
        end
        location = _clone.edit_path + gwbbs_params_set
        format.html { redirect_to location }
      else
        flash.now[:notice] = t("rumi.message.notice.copy_fail")
        location = item.show_path + gwbbs_params_set
        format.html { redirect_to location }
      end
    end
  end

  def copy_attached_files(item, clone)
    files = Gwcircular::File.where(title_id: item.title_id, parent_id: item.id)
                            .order('id')
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

    total = Gwcircular::File.where('unid = 1').sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = Gwcircular::File.where('unid = 2').sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save
  end

  def is_integer(no)
    chg = no.to_s
    return chg.to_i
  end
end

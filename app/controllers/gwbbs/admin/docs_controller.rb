# -*- encoding: utf-8 -*-
class Gwbbs::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwbbs::Admin::DocsHelper
  include Gwbbs::Controller::AdmsInclude

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  protect_from_forgery :except => [:mail_forward]
  layout :select_layout
  require 'base64'
  require 'zlib'

  def initialize_scaffold
    @title = Gwbbs::Control.find_by(id: params[:title_id])
    @piece_head_title = I18n.t("rumi.bbs.name")
    @side = "gwbbs"
    @forward = false
    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    return http_error(404) unless @title
    return redirect_to("/gwbbs/docs?title_id=#{params[:title_id]}&state=#{params[:state]}") if params[:reset]

    begin
      _category_condition
    rescue
      return http_error(404)
    end

    initialize_value_set_new_css

    params[:state] = @title.default_mode if params[:state].blank?
    Page.title = @title.title

    params[:piece_param] = "TitleDisplayMode"
    get_piece_menus
  end

  def _category_condition
    @categories1 = []
    @d_categories = []
  end

  def index
    get_role_index
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'CATEGORY'
      category_index
    when 'RECOGNIZE'
      recognize_index
    when 'PUBLISH'
      recognized_index
    else
      date_index
    end

    void_item if @gw_admin if params[:state].to_s == 'VOID'

    #添付ファイルの検索を行う
    unless params[:kwd].blank?
      item = Gwbbs::File
      item = item.where("gwbbs_files.title_id = ?", params[:title_id])
                 .where(gwbbs_select_status(params))
      item = item.search(params)
      item = item.where("gwbbs_docs.able_date >= ?", params[:startdate].to_s.to_time.strftime("%Y-%m-%d") + " 00:00:00") unless params[:startdate] == ''
      item = item.where("gwbbs_docs.able_date <= ?", params[:enddate].to_s.to_time.strftime("%Y-%m-%d") + " 23:59:59") unless params[:enddate] == ''
      @files = item.joins('inner join gwbbs_docs on gwbbs_files.parent_id = gwbbs_docs.id')
                   .select('gwbbs_files.*').order("filename")
                   .paginate(page: params[:page]).limit(params[:limit])
    end
    Page.title = @title.title
  end

  def show
    get_role_index
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_readable

    @is_recognize = check_recognize
    @is_recognize_readable = check_recognize_readable

    @item = @title.docs.where(id: params[:id]).where(gwbbs_select_status(params)).first
    return http_error(404) unless @item

    @is_recognize = false unless @item.state == 'recognize'

    get_role_show(@item)  #admin, readable, editable
    @is_readable = true if @is_recognize_readable
    return authentication_error(403) unless @is_readable

    case params[:state].to_s
    when 'CATEGORY'
      category_index(true)
    when 'RECOGNIZE'
      #recognize_index(true)
    when 'PUBLISH'
      #recognized_index(true)
    else
      date_index(true)
    end
    return http_error(404) unless @items

    if params[:pp].blank?
      fip = 0
      for item_pp in @items
        fip += 1
        params[:pp] = fip
        break if item_pp.id == params[:id].to_i
      end
    end
    current = params[:pp]
    current = 1 unless current
    current = current.to_i

    @prev_page = current - 1
    @prev_page = nil if @prev_page < 1
    unless @prev_page.blank?
      @previous = @items[@prev_page - 1]
    else
      @previous = nil
    end
    #次
    @next_page = current + 1
    @next_page = nil if @items.length < @next_page
    unless @next_page.blank?
      @next = @items[@next_page - 1]
    else
      @next = nil
    end
    
    @comment = Gwbbs::Comment.new({
      :state => 'public' ,
      :published_at => Core.now ,
    })

    @comments = Gwbbs::Comment.where(title_id: params[:title_id], parent_id: @item.id).order('created_at')

    @files = Gwbbs::File.where(title_id: params[:title_id], parent_id: @item.id).order('id')
    get_recogusers

    # 既読処理
    @item.seen_remind(Core.user.id)

    @is_publish = true if @gw_admin if @item.state == 'recognized'
    @is_publish = true if @item.section_code.to_s == Core.user_group.code.to_s if @item.state == 'recognized'

    ptitle = ''
    ptitle = @title.notes_field09 unless @title.notes_field09.blank? if @title.form_name == 'form003'
    ptitle = @item.title unless @title.form_name == 'form003'
    Page.title = ptitle unless ptitle.blank?

    @item.seen_reply_remind(Core.user.id) if params[:comment_read].present?

    return all_download if params[:download]=='full_download'
    return download unless params[:download].blank?
  end

  def gwcircular_forward
    @item = @title.docs.where(id: params[:id]).first
    @forward_form_url = "/gwcircular/forward"
    @target_name = "gwcircular_form"
    forward_setting
  end

  def mail_forward
    @item = @title.docs.where(id: params[:id]).first
    _url = Enisys::Config.application["webmail.root_url"]
    @forward_form_url = URI.join(_url, "/_admin/gw/webmail/INBOX/mails/gw_forward").to_s
    @target_name = "mail_form"
    forward_setting
  end

  def forward_setting
    #機能間転送の為の処理
    #本文の処理
    @gwbbs_text_body = "-------- Original Message --------<br />"
    #本文_タイトル
    @gwbbs_text_body << I18n.t('rumi.message.forward_message.gwbbs.title') + " " + ERB::Util.html_escape(@item.title) + "<br />"
    #本文_作成日時
    @gwbbs_text_body << I18n.t('rumi.message.forward_message.gwbbs.create_date') + " " + (I18n.l @item.created_at).to_s + "<br />"
    #本文_作成者
    @gwbbs_text_body << I18n.t('rumi.message.forward_message.gwbbs.creator') + " " + @item.name_creater_section + " " + @item.creater + "<br />"
    #本文_回覧記事本文
    @gwbbs_text_body << @item.body
    @gwbbs_text_body = Base64.encode64(@gwbbs_text_body).split().join()

    @tmp = ""
    @name = ""
    @content_type = ""
    @size = ""

    forward = Gwbbs::File.where(parent_id: @item.id)
    forward.each do |attach|
      f = File.open(attach.f_name)
      @tmp.concat "," if @tmp.present?
      tmp = Zlib::Deflate.deflate(f.read, Zlib::BEST_COMPRESSION)
      @tmp.concat Base64.encode64(tmp).split().join()
      @name.concat "," if @name.present?
      @name.concat attach.filename.to_s
      @content_type.concat "," if @content_type.present?
      @content_type.concat attach.content_type.to_s
      @size.concat "," if @size.present?
      @size.concat attach.size.to_s
    end
  end

  def get_recogusers
    @recogusers = @title.docs.where(title_id: params[:title_id], parent_id: params[:id]).order('id')
  end

  def new
    get_role_new
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 3 unless default_published

    @item = Gwbbs::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 1,
      :title => '',
      :body => '',
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => "#{default_published.months.since.strftime("%Y-%m-%d")} 23:59:59",
      #表示する名称 初期表示：所属名のみ
      :name_type => 1,
      #表示する所属 初期表示：自所属
      :name_editor_section_id => Core.user_group.code,
      :name_editor_section => Core.user_group.name
    })

    @item.state = 'draft'
    users_collection unless @title.recognize == 0
  end

  def forward
    get_role_new
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 3 unless default_published

    title = ''
    body = ''

    #件名が存在すればタイトルに挿入
    title = params[:title].to_s if params[:title].present?

    #本文が存在すれば本文に挿入
    __body = Base64.decode64(params[:body]).to_s if params[:body].present?
    if params[:body].present? && __body.include?("<")
      body = __body.force_encoding("utf-8")
    else
      _body = __body.split("\r\n");
      _body.each do |b|
        body << b.force_encoding("utf-8") + "<br />"
      end
    end

    @item = Gwbbs::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 1,
      :title => title,
      :body => body,
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => "#{default_published.months.since.strftime("%Y-%m-%d")} 23:59:59",
      #表示する名称 初期表示：ユーザー名と所属名
      :name_type => 2,
      #表示する所属 初期表示：自所属
      :name_editor_section_id => Core.user_group.code,
      :name_editor_section => Core.user_group.name
    })

    @item.state = 'draft'

    #添付ファイルが存在すれば添付ファイルのコピーを行う
    if params[:tmp].present?
      forward = params[:tmp].split(",")
      name = params[:name].split(",")
      content_type = params[:content_type].split(",")
      size = params[:size].split(",")
      # 添付ファイル情報コピー
      cnt = 0
      forward.each do |attach|
        @max_size = is_integer(@title.upload_document_file_size_max)
        @max_size = 3 unless @max_size
        if @max_size.megabytes < size[cnt].to_i
          if size[cnt] != 0
            mb = size[cnt].to_f / 1.megabyte.to_f
            mb = (mb * 100).to_i
            mb = sprintf('%g', mb.to_f / 100)
          end
          flash.now[:notice] = I18n.t('rumi.attachment.message.fail_exceed_max_size',max_size: @max_size, file_size: mb)
        else
          begin
            filename = "attach_" + cnt.to_s
            tmpfile = Tempfile.new(filename)

            t_file = File.open(tmpfile.path,"w+b")
            at = Base64.decode64(attach)
            t_file.write(Zlib::Inflate.inflate(at))
            t_file.close
            title_id = 1
            title_id = params[:title_id] if params[:title_id].present?
            upload = ActionDispatch::Http::UploadedFile.new({
              :filename => name[cnt],
              :content_type => content_type[cnt],
              :size => size[cnt],
              :memo => '',
              :title_id => title_id,
              :parent_id => @item.id,
              :content_id => @title.upload_system,
              :db_file_id => 0,
              :tempfile => File.open(t_file.path)
            })

            tmpfile = Gwbbs::File.new({
              :content_type => content_type[cnt],
              :filename => name[cnt],
              :size => size[cnt],
              :memo => '',
              :title_id => title_id,
              :parent_id => @item.id,
              :content_id => @title.upload_system,
              :db_file_id => 0
            })
            tmpfile._upload_file(upload)
            tmpfile.save
          rescue => ex
            if ex.message=~/File name too long/
              flash.now[:notice] = I18n.t('rumi.attachment.message.name_too_long')
            else
              flash.now[:notice] = ex.message
            end
          end
        end
        cnt = cnt + 1
      end
    end
    users_collection unless @title.recognize == 0
    @forward = true

    render action: :new, layout: "admin/template/forward_form"
  end

  def close
    get_role_new
  end

  def edit
    get_role_new
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_writable

    item = @title.docs
    @item = item.where(id: params[:id]).first
    return http_error(404) unless @item
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
    @item.category4_id = 0 if @item.category4_id.blank?
    unless @title.recognize == 0
      get_recogusers
      set_recogusers
      users_collection('edit')
    end
    Page.title = @title.title
  end

  def set_recogusers
    @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
    i = 0
    for recoguser in @recogusers
      i += 1
      @select_recognizers[i.to_s] = recoguser.user_id.to_s
    end
  end

  def update
    get_role_new
    return http_error(404) unless @gw_admin || @title.state == 'public'
    return http_error(404) unless @gw_admin || @title.view_hide
    return authentication_error(403) unless @is_writable
    unless @title.recognize.to_s == '0'
      users_collection
    end

    item = Gwbbs::File
    @files = item.where(title_id: params[:title_id], parent_id: params[:id]).order('id')

    attach = 0
    attach = @files.length unless @files.blank?

    @item = Gwbbs::Doc.find(params[:id])

    @before_state = @item.state
    before_able_date = @item.able_date

    @item.attributes = item_params
    @item.latest_updated_at = Time.now

    unless @item.expiry_date.blank?
      #@item.expiry_date = "#{@item.expiry_date.strftime("%Y-%m-%d")} 23:59:59"  if @item.expiry_date.strftime('%H:%M') == '00:00'
    end
    @item.attachmentfile = attach
    @item.category_use = @title.category
    @item.form_name = @title.form_name

    update_creater_editor   #Gwboard::Controller::Common

    # 表示する作成グループ
    if @item.name_creater_section_id.blank? || @item.editor.blank? || (@item.able_date && @item.able_date > Time.now)
      item_create = Gwboard::Group.where(code: @item.name_editor_section_id).first
      unless @item.name_type == 0
        @item.name_creater_section_id = @item.name_editor_section_id
        @item.name_creater_section = item_create.name if @item.name_editor_section_id.present?
      else
        @item.name_creater_section_id = Core.user_group.code
        @item.name_creater_section = Core.user_group.name
      end
    end

    # 表示する編集グループ
    item_update = Gwboard::Group.where(code: @item.name_editor_section_id).first
    unless @item.name_type == 0
      @item.name_editor_section = item_update.name if @item.name_editor_section_id.present?
    else
      @item.name_editor_section_id = Core.user_group.code
      @item.name_editor_section = Core.user_group.name
    end

    if @item.able_date && @item.able_date > Time.now
      @item.createdate = @item.able_date.strftime("%Y-%m-%d %H:%M")
      @item.creater_id = Core.user.code unless Core.user.code.blank?
      @item.creater = Core.user.name unless Core.user.name.blank?
      @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
      @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?
      @item.editor_id = Core.user.code unless Core.user.code.blank?
      @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
      @item.creater_admin = @gw_admin
      @item.editor_admin = @gw_admin
      @item.editdate = ''
      @item.editor = ''
      @item.editordivision = ''

      @item.latest_updated_at = @item.able_date
    end

    @item.inpfld_006 = ''
    @item.inpfld_006 = ''
    @item.inpfld_006w = ''
    @item.inpfld_006w = ''

    group = Gwboard::Group.where(state: 'enabled', code: @item.section_code).first
    @item.section_name = group.name if group
    @item._note_section = group.name if group
    @item._bbs_title_name = @title.title
    @item._notification = @title.notification

    case @item.state
    when 'public'
      next_location = "#{@title.docs_path}"
    when 'draft'
      next_location = "#{@title.docs_path}&state=DRAFT"
    when 'recognize'
      next_location = "#{@title.docs_path}&state=RECOGNIZE"
    else
      next_location = "#{@title.docs_path}#{gwbbs_params_set}"
    end
    if params[:request_path].present?
      next_location = "/gwbbs/docs/close?title_id=" + params[:title_id]
    end
    if @title.recognize == 0
      _update_plus_location(@item, next_location, {notice: params[:message]}) if params[:request_path].blank?
      _update_plus_location(@item, next_location, {notice: params[:message], :request_path=>params[:request_path]}) if params[:request_path].present?
    else
      #recog_item = Gwbbs::Recognizer
      #_update_after_save_recognizers(@item, recog_item, next_location) if params[:request_path].blank?
      #_update_after_save_recognizers(@item, recog_item, next_location, :request_path=>params[:request_path]) if params[:request_path].present?
    end
  end

  def destroy
    @item = @title.docs.find(params[:id])
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable

    destroy_comments
    destroy_atacched_files
    #destroy_files

    @item._notification = @title.notification
    _destroy_plus_location(@item, "#{@title.docs_path}#{gwbbs_params_set}" )
  end

  def destroy_void_documents
    return authentication_error(403) unless @gw_admin

    @items = @title.docs.where(state: 'preparation')
                        .where("created_at < ?", Date.yesterday.strftime("%Y-%m-%d") + ' 00:00:00')
    for @item in @items
      destroy_comments
      destroy_atacched_files
      #destroy_files
      @item.destroy
    end

    @items = @title.docs.where(state: 'public').where("expiry_date < ?", Date.today.strftime("%Y-%m-%d") + ' 00:00:00')
    for @item in @items
      destroy_comments
      destroy_atacched_files
      #destroy_files
      @item.destroy
    end
    redirect_to "#{@title.docs_path}#{gwbbs_params_set}"
  end

  def category_index(no_paginate=nil)
    item = @title.docs.draft_docs.where(gwbbs_select_status(params))
    @items = item.search(params,@title.form_name).order(gwboard_sort_key_bbs)
               .select('gwbbs_docs.*')
               .paginate(page: params[:page]).limit(params[:limit])
  end

  def date_index(no_paginate=nil)
    @items = @title.docs.where(gwbbs_select_status(params))
                        .search(params,@title.form_name).order(gwboard_sort_key_bbs)
                        .paginate(page: params[:page]).limit(params[:limit])
  end

  def void_item
    @void_items = @title.docs.where(title_id: params[:title_id]).where(gwbbs_select_status(params))
                        .search(params,@title.form_name).select('id')
                        .paginate(page: params[:page]).limit(params[:limit])
  end

  def recognize_index(no_paginate=nil)
    sql = Condition.new
    sql.or {|d|
      d.and "sql", "gwbbs_docs.section_code = '#{Core.user_group.code}'" unless @gw_admin
    }
    sql.or {|d|
      d.and "sql", "gwbbs_recognizers.code = '#{Core.user.code}'"
    }
    join = "INNER JOIN gwbbs_recognizers ON gwbbs_docs.id = gwbbs_recognizers.parent_id AND gwbbs_docs.title_id = gwbbs_recognizers.title_id"
    @items = @title.docs.recognizable_docs.joins(join).where(sql.where).order('latest_updated_at DESC').group('gwbbs_docs.id')
                   .paginate(page: params[:page]).limit(params[:limit])
  end

  def recognized_index(no_paginate=nil)
    @items = @title.docs.recognized_docs.where(gwbbs_select_status(params))
                               .search(params)
                               .order(gwboard_sort_key(params))
                               .paginate(page:params[:page]).limit(params[:limit])
  end

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_comments
    item = Gwbbs::Comment
    item.where(sql_where).destroy_all
  end

  def destroy_atacched_files
    item = Gwbbs::File
    item.where(sql_where).destroy_all
    total = item.where('unid = 1').sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f
    total = item.where('unid = 2').sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f
    @title.save
  end

  def clone
    item = Gwbbs::Doc
    @item = item.where(id: params[:id]).first
    return http_error(404) unless @item
    get_role_edit(@item)
    clone_doc(@item)
  end

  def edit_file_memo
    get_role_index
    return authentication_error(403) unless @is_readable

    item = Gwbbs::Doc
    @item = item.where(id: params[:parent_id]).first
    Gwbbs::Doc.remove_connection
    return http_error(404) unless @item
    get_role_show(@item)

    item = Gwbbs::Comment
    @comments = item.where(title_id: params[:title_id], parent_id: @item.id).order('latest_updated_at DESC')

    item = Gwbbs::File
    @files = item.where(title_id: params[:title_id], parent_id: @item.id)
               .order('id')

    item = Gwbbs::File
    @file = item.find(params[:id])
  end

  def publish_update
    item = @title.docs.recognized_docs.where(id: params[:id]).first
    if item
      item.state = 'public'
      item.published_at = Time.now
      item.save
    end
    redirect_to(@title.docs_path)
  end

  def recognize_update
    #item = Gwbbs::Recognizer
    #item = item.where(title_id: params[:title_id], parent_id: params[:id], code: Core.user.code).first
    #if item
    #  item.recognized_at = Time.now
    #  item.save
    #end

    #item = item.where(title_id: params[:title_id], parent_id: params[:id])
    #           .where("recognized_at is NULL")

    #if item.length == 0
    #  item = Gwbbs::Doc
    #  item = item.find(params[:id])
    #  item.state = 'recognized'
    #  item.recognized_at = Time.now
    #  item.save

    #  user = System::User.find_by_code(item.editor_id.to_s)
    #  unless user.blank?
    #    Gw.add_memo(user.id.to_s, "#{@title.title}「#{item.title}」について、全ての承認が終了しました。", "次のボタンから記事を確認し,公開作業を行ってください。<br /><a href='#{item.show_path}&state=PUBLISH'><img src='/_common/themes/gw/files/bt_openconfirm.gif' alt='公開処理へ' /></a>",{:is_system => 1})
    #  end
    #end
    #get_role_new
    #redirect_to("#{@title.docs_path}") unless @is_writable
    #redirect_to("#{@title.docs_path}&state=RECOGNIZE") if @is_writable
  end

  def check_recognize
    #item = Gwbbs::Recognizer
    #item = item.where(title_id: params[:title_id], parent_id: params[:id], code: Core.user.code)
    #           .where("recognized_at is null")
    ret = nil
    #ret = true if item.length != 0
    return ret
  end

  # === 記事管理課チェックメソッド
  #  本メソッドは、記事管理課にログインユーザーが所属しているかチェックを行うメソッド
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  true : 所属している    false : 所属していない
  def check_section_group?()
    user_group1 = System::UsersGroup.where(:user_code => Core.user.code, :group_code => @item.section_code).first
    return user_group1.blank? ? false : true
  end

  # === 閲覧画面権限取得メソッド
  #  本メソッドは、閲覧画面にログインユーザーの権限が存在するか取得を行うメソッド
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  * なし
  def get_role_show(item)
    get_readable_flag
    get_editable_flag(item)
  end

  # === 編集権限取得メソッド
  #  本メソッドは、ログインユーザーが編集権限を持っているか取得を行うメソッド
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  * なし
  def get_editable_flag(item)
    if @gw_admin
      @is_editable = true
    else
      get_writable_flag
      @is_editable = true if check_section_group?() if @is_writable
    end
  end

  def check_recognize_readable
    #item = Gwbbs::Recognizer
    #item = item.where(title_id: params[:title_id], parent_id: params[:id], code: Core.user.code)
    ret = nil
    #ret = true if item.length != 0
    return ret
  end

  # === 一括既読メソッド
  #  本メソッドは、チェックが入った記事を一括既読にするメソッド
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  * なし
  def all_seen_remind
    if params[:ids] and params[:ids].size > 0
      params[:ids].each do |key, value|
        doc_item = Gwbbs::Doc.find(key)
        doc_item.seen_remind(Core.user.id)
      end
    end
    redirect_uri = params[:fullPath]
    redirect_to redirect_uri
  end

private

  def item_params
    params.require(:item)
          .permit(:title, :body, :one_line_note, :able_date, :expiry_date, :section_code, :name_type, :name_editor_section_id,
                  :importance, :inpfld_001, :state)
  end

  def invalidtoken
    return http_error(404)
  end

  def gwboard_sort_key_bbs
    ret = ''
    ret = gwboard_sort_key(params,'gwbbs') unless @title.form_name == 'form006'
    ret = gwboard_sort_key_form006 if @title.form_name == 'form006'
    return ret
  end

  def gwboard_sort_key_form006()
    str = ''
    case params[:state]
    when "GROUP"
      str = 'inpfld_002, inpfld_006d DESC, latest_updated_at DESC'
    when "CATEGORY"
      str = 'category1_id, inpfld_006d DESC, latest_updated_at DESC'
    else
      str = 'inpfld_006d DESC, latest_updated_at DESC'
    end
    return str
  end

  def gwboard_sort_key_form007()
    str = ''
    case params[:state]
    when "GROUP"
      str = 'inpfld_002, inpfld_006d DESC, latest_updated_at DESC'
    when "CATEGORY"
      str = 'category1_id, inpfld_006d DESC, latest_updated_at DESC'
    else
      str = 'inpfld_006d DESC, latest_updated_at DESC'
    end
    return str
  end

  def all_download
    require "mail"

    mail = Mail.new
    mail.from    = @item.editor.present? ? @item.editor.to_s : @item.creater.to_s
    mail.subject = @item.title.to_s

    mail_body = @item.body
    text_html = Mail::Part.new do
      body mail_body
      content_type "text/html"
    end
    mail.html_part = text_html

    for item in @files
      mail.attachments["#{item.filename}"] = File.read("#{item.f_name}")
    end

    mail.attachments.each do |at|
      if at.content_type == "text/plain"
        at.content_type = "application/zip"
      end
    end

    title = @item.title.gsub(/[\/\<\>\|:;"\?\*\\\r\n]/, '_')
    title = title.match(/^.{100}/).to_s if title.length > 100
    title = URI::escape(title)
    filename = "#{URI::escape("(#{@piece_head_title})")}_#{@item.able_date.strftime('%Y%m%d')}_#{title}.eml"
    send_data(mail.to_s, :filename => filename,
        :type => 'message/rfc822', :disposition => 'attachment')
  end

  def download
    unless File.exist?(Rumi::Gwbbs::ZipFileUtils::TMP_FILE_PATH)
      FileUtils.mkdir_p(Rumi::Gwbbs::ZipFileUtils::TMP_FILE_PATH)
    end

    zip_data = {}
    for attache_file in @files
      # zipファイル情報の保存
      zip_data["#{attache_file.filename}"] =
        attache_file.f_name
    end

    target_zip_file = File.join(
        Rumi::Gwbbs::ZipFileUtils::TMP_FILE_PATH,
        "#{request.session_options[:id]}.zip")

    Rumi::Gwbbs::ZipFileUtils.zip(
        target_zip_file,
        zip_data,
        {:fs_encoding => Rumi::Gwbbs::ZipFileUtils::ZIP_ENCODING})

    title = @item.title.gsub(/[\/\<\>\|:;"\?\*\\\r\n]/, '_')
    title = title.match(/^.{100}/).to_s if title.length > 100
    title = URI::escape(title)
    bbs_head_name = I18n.t('rumi.gwbbs.download.tmpfile')
    filename = "#{URI::escape("(#{bbs_head_name})")}_#{@item.able_date.strftime('%Y%m%d')}_#{title}.zip"
    send_file target_zip_file ,
        :filename => filename if FileTest.exist?(target_zip_file)
  end

protected

  def select_layout
    layout = "admin/template/portal"
    case params[:action].to_sym
    when :gwcircular_forward, :mail_forward
      layout = "admin/template/forward_form"
    end
    layout
  end
end

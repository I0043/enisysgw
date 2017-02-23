# encoding:utf-8
class Gwcircular::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize
  include Gwcircular::DocsHelper
  require 'base64'
  require 'zlib'

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  protect_from_forgery :except => [:forward]
  layout :select_layout

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    Page.title = t('rumi.circular.name')
    @piece_head_title = t('rumi.circular.name')
    @side = "gwcircular"
    @forward = false
    s_cond = ''
    s_cond = "?cond=#{params[:cond]}" unless params[:cond].blank?
    return redirect_to("#{gwcircular_menus_path}#{s_cond}") if params[:reset]


    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank?

      item = Gwcircular::Doc.find_by(id: params[:id])
      unless item.blank?

        if item.doc_type == 0
          params[:cond] = 'owner'
        end unless params[:cond] == 'void'
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end unless params[:cond] == 'void'
      end
    end unless params[:cond] == 'void' unless params[:cond] == 'admin'
    params[:cond] = 'unread' if params[:cond].blank?

    get_piece_menus
  end

  def jgw_circular_path
    return gwcircular_menus_path
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable
    case params[:cond]
    when 'unread'
      unread_index
    when 'already'
      already_read_index
    when 'owner'
      owner_index
    when 'void'
      owner_index
    when 'admin'
      return authentication_error(403) unless @gw_admin
      admin_index
    else
      unread_index
    end

    #添付ファイルの検索を行う
    unless params[:kwd].blank?
      search_file_index
    end
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    @item = Gwcircular::Doc.where(id: params[:id]).first
    return http_error(404) unless @item

    get_role_show(@item)  #admin, readable, editable

    @is_readable = false unless @item.target_user_code == Core.user.code unless @gw_admin
    return authentication_error(403) unless @is_readable

    # 添付ファイルの取得
    @files = Gwcircular::File.where(:parent_id => @item.id)


    # コメント通知の既読処理
    @item.seen_reply_remind(Core.user.id) if params[:comment_read].present?

    commission_index

    return all_download if params[:download]=='full_download'
  end

  def gwbbs_forward
    @item = Gwcircular::Doc.where(id: params[:id]).first
    return http_error(404) unless @item

    @forward_form_url = "/gwbbs/forward_select"
    @target_name = "gwbbs_form_select"
    forward_setting
  end

  def mail_forward
    @item = Gwcircular::Doc.where(id: params[:id]).first
    return http_error(404) unless @item

    _url = Enisys::Config.application["webmail.root_url"]
    @forward_form_url = URI.join(_url, "/_admin/gw/webmail/INBOX/mails/gw_forward").to_s
    @target_name = "mail_form"

    forward_setting
  end

  def forward_setting
    #機能間転送の為の処理
    #本文の処理
    @gwcircular_text_body = "-------- Original Message --------<br />"
    #本文_タイトル
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.title') + " " + ERB::Util.html_escape(@item.title) + "<br />"
    #本文_作成日時
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.create_date') + " " + (I18n.l @item.created_at).to_s + "<br />"
    #本文_作成者
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.creator') + " " + @item.createrdivision + " " + @item.creater + "<br />"
    #本文_回覧記事本文
    @gwcircular_text_body << @item.body
    @gwcircular_text_body = Base64.encode64(@gwcircular_text_body).split().join()

    @tmp = ""
    @name = ""
    @content_type = ""
    @size = ""
    forward = Gwcircular::Doc.find_by(id: @item.id)
    forward.files.each do |attach|
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

  def new
    get_role_new
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 14 unless default_published

    title = ''
    head = ''
    body = ''
    _body = ''
    readers_json = []
    spec_config = 3
    importance = 1
    cnt = 0
    forward_flg = false
    copy_flg = false
    expiry_date = default_published.days.since.strftime("%Y-%m-%d %H:00")

    if params[:forward_id].present?
      forward_flg = true
      @forward_id = params[:forward_id]
    end
    if params[:copy_id].present?
      copy_flg = true
      @forward_id = params[:copy_id]
    end

    if params[:forward_id].present? || params[:copy_id].present?
      forward = Gwcircular::Doc.get_forward(@forward_id)

      return authentication_error(500) if forward.blank?

      forward.each do |f|
        title = I18n.t('rumi.message.forward_message.gwcircular.forward') + " " + ERB::Util.html_escape(f.title)
        if f.parent_id.present?
          parent = Gwcircular::Doc.where(id: f.parent_id).first

          #本文_タイトル
          head << I18n.t('rumi.message.forward_message.gwcircular.title') + " " + ERB::Util.html_escape(parent.title) + "<br />"

          #本文_作成日時
          head << I18n.t('rumi.message.forward_message.gwcircular.create_date') + " " + (I18n.l parent.created_at).to_s + "<br />"

          #本文_作成者
          head << I18n.t('rumi.message.forward_message.gwcircular.creator') + " " + parent.createrdivision + " " + parent.creater + "<br />"

          #本文_回覧記事本文
          body << parent.body

          @forward_id = parent.id
        else
          #本文_タイトル
          head << I18n.t('rumi.message.forward_message.gwcircular.title') + " " + ERB::Util.html_escape(f.title) + "<br />"

          #本文_作成日時
          head << I18n.t('rumi.message.forward_message.gwcircular.create_date') + " " + (I18n.l f.created_at).to_s + "<br />"

          #本文_作成者
          head << I18n.t('rumi.message.forward_message.gwcircular.creator') + " " + f.createrdivision + " " + f.creater + "<br />"

          #本文_回覧記事本文
          body << f.body
        end

        if forward_flg
          title = I18n.t('rumi.message.forward_message.gwcircular.forward') + " " + f.title
          body = "-------- Original Message --------<br />" + head + "---<br /><br />" + body
          body << "<br />------ Original Message Ends ------<br />"
        end

        target_users = []
        if copy_flg
          if f.parent_id.blank? || (f.spec_config.present? && f.spec_config.to_i != 0)
            title = f.title
            users = System::User.without_disable
            if f.parent_id.present?
              item = parent
            else
              item = f
            end
            if item.reader_groups_json.present?
              group_infos = JsonParser.new.parse(item.reader_groups_json)
              group_infos.each do |group_info|
                readers_json << group_info
                target_users << group_info[1]
              end
            end
            if item.readers_json.present?
              user_infos = JsonParser.new.parse(item.readers_json)
              user_infos.each do |user_info|
                readers_json << user_info unless target_users.find{|x| x == user_info[1]}
                target_users << user_info[1]
              end
            end
          end
        end
        readers_json = readers_json.to_json
        unless f.expiry_date < Time.now
          expiry_date = f.expiry_date
        end
        importance = f.importance.to_i if f.importance.present?
        spec_config = f.spec_config.to_i if f.spec_config.present?

        if parent.blank?
          files = Gwcircular::File.find_by_parent_id(f.id)
        else
          files = Gwcircular::File.find_by_parent_id(parent.id)
        end
        if files.present?
          cnt = 1
        end
      end
    end

    @item = Gwcircular::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :doc_type => 0,
      :title => title,
      :body => body,
      :section_code => Core.user_group.code,
      :target_user_id => Core.user.id,
      :target_user_code => Core.user.code,
      :target_user_name => Core.user.name,
      :confirmation => 0,
      :spec_config => spec_config,
      :importance => importance,
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => expiry_date,
      :readers_json => readers_json
    })
    @item.state = 'draft'

    if cnt == 1
      forward = Gwcircular::Doc.find_by(id: @forward_id)
      copy_file = Gwcircular::Doc.new
      # 添付ファイル情報コピー
      forward.files.each do |attach|
        attributes = attach.attributes.reject do |key, value|
          key == 'id' || key == 'parent_id'
        end
        attach_file = copy_file.files.build(attributes)
        attach_file.created_at = Time.now
        attach_file.updated_at = Time.now

        # 添付ファイルの存在チェック
        unless File.exist?(attach.f_name)
          raise I18n.t('rumi.doclibrary.drag_and_drop.message.attached_file_not_found')
        end
        upload = ActionDispatch::Http::UploadedFile.new({
          :filename => attach.filename,
          :content_type => attach.content_type,
          :size => attach.size,
          :memo => attach.memo,
          :title_id => attach.title_id,
          :parent_id => attach.parent_id,
          :content_id => @title.upload_system,
          :db_file_id => 0,
          :tempfile => File.open(attach.f_name)
        })
        attach_file._upload_file(upload)
        attach_file.parent_id = @item.id
        attach_file.save
      end
    end

  end

  def reply
    get_role_new
    return authentication_error(403) unless @is_writable

    default_published = is_integer(@title.default_published)
    default_published = 14 unless default_published

    title = ''
    head = ''
    body = ''
    readers_json = []
    spec_config = 3
    importance = 1
    cnt = 0
    expiry_date = default_published.days.since.strftime("%Y-%m-%d %H:00")

    reply_base = Gwcircular::Doc.where(id: params[:id]).first
    title = "Re: " + reply_base.title
    body = " <br />"
    if reply_base.parent_id.present?
      parent = Gwcircular::Doc.where(id: reply_base.parent_id).first
      reply = parent
    else
      reply = reply_base
    end

    #返信元情報
    #本文_タイトル
    head << I18n.t('rumi.message.forward_message.gwcircular.title') + " " + ERB::Util.html_escape(reply.title) + "<br />"
    #本文_作成日時
    head << I18n.t('rumi.message.forward_message.gwcircular.create_date') + " " + (I18n.l reply.created_at).to_s + "<br />"
    #本文_作成者
    head << I18n.t('rumi.message.forward_message.gwcircular.creator') + " " + reply.createrdivision + " " + reply.creater + "<br />"


    body << "<blockquote style='margin: 2px 0px 2px 5px; padding: 0px 0px 0px 5px; border-left-style: solid; border-left-width: 2px; border-left-color: silver;'>"
    body << "-------- Original Message ---------<br />"
    body << head
    body << "---<br /><br />"
    body << reply.body.to_s.gsub(/\r\n/, "<br />").gsub(/\n/, "<br />")
    body << "<br />------ Original Message Ends ------<br />"
    body << "</blockquote>"

    target_user = Array.new
    target_user_ids = Array.new
    if reply.editor_id.present?
      editor_info = System::User.where(code: reply.editor_id).first
      editor = [nil,editor_info.id.to_s,editor_info.name]
      target_user << editor
      target_user_ids << editor_info.id.to_s
    else
      creator_info = System::User.where(code: reply.creater_id).first
      creator = [nil,creator_info.id.to_s,creator_info.name]
      target_user << creator
      target_user_ids << creator_info.id.to_s
    end

    #全員に返信するクリック時、他の宛先も対象
    if params[:all] == '1' && ((reply_base.parent_id.present? && reply_base.spec_config != 0) || reply_base.parent_id.blank?)
      if reply.reader_groups_json.present?
        group_infos = JsonParser.new.parse(reply.reader_groups_json)
        group_infos.each do |group_info|
          user = target_user_ids.find{|x| x == group_info[1]}
          if user.blank? && Core.user.id.to_s != group_info[1].to_s
            target_user << group_info
            target_user_ids << group_info[1]
          end
        end
      end

      if reply.readers_json.present?
        user_infos = JsonParser.new.parse(reply.readers_json)
        user_infos.each do |user_info|
          user = target_user_ids.find{|x| x == user_info[1]}
          if user.blank? && Core.user.id.to_s != user_info[1].to_s
            target_user << user_info
            target_user_ids << user_info[1]
          end
        end
      end
    end
    readers_json = target_user.to_json

    @item = Gwcircular::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :doc_type => 0,
      :title => title,
      :body => body,
      :section_code => Core.user_group.code,
      :target_user_id => Core.user.id,
      :target_user_code => Core.user.code,
      :target_user_name => Core.user.name,
      :confirmation => 0,
      :spec_config => spec_config,
      :importance => importance,
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => expiry_date,
      :readers_json => readers_json
    })
    @item.state = 'draft'
  end

  def forward
    params[:authenticity_token] = form_authenticity_token
    get_role_new
    return authentication_error(403) unless @is_writable
    default_published = is_integer(@title.default_published)
    default_published = 14 unless default_published
    title = ''
    body = ''
    readers_json = []
    spec_config = 3
    importance = 1
    expiry_date = default_published.days.since.strftime("%Y-%m-%d %H:00")

    #件名が存在すれば回覧板のタイトルに挿入
    title = params[:title] if params[:title].present?

    #本文が存在すれば回覧板の本文に挿入
    __body = Base64.decode64(params[:body]).to_s if params[:body].present?
    if params[:body].present? && __body.include?("<")
      body = __body.force_encoding("utf-8")
    else
      _body = __body.split("\r\n");
      _body.each do |b|
        body << b.force_encoding("utf-8") + "<br />"
      end
    end

    @item = Gwcircular::Doc.create({
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :doc_type => 0,
      :title => title,
      :body => body,
      :section_code => Core.user_group.code,
      :target_user_id => Core.user.id,
      :target_user_code => Core.user.code,
      :target_user_name => Core.user.name,
      :confirmation => 0,
      :spec_config => spec_config,
      :importance => importance,
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => expiry_date,
      :readers_json => readers_json
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
        if content_type[cnt].index("image").blank?
          @max_size = is_integer(@title.upload_document_file_size_max)
        else
          @max_size = is_integer(@title.upload_graphic_file_size_max)
        end
        @max_size = 5 if @max_size.blank?
        if @max_size.megabytes < size[cnt].to_i
          if size[cnt] != 0
            mb = size[cnt].to_f / 1.megabyte.to_f
            mb = (mb * 100).to_i
            mb = sprintf('%g', mb.to_f / 100)
          end
          flash.now[:notice] = I18n.t('rumi.attachment.message.fail_exceed_max_size',max_size: @max_size, file_size: mb)
        elsif name[cnt].bytesize > Enisys.config.application['sys.max_file_name_length']
          flash.now[:notice] = I18n.t('rumi.attachment.message.name_too_long')
        else
          begin
            filename = "attach_" + cnt.to_s
            tmpfile = Tempfile.new(filename)

            t_file = File.open(tmpfile.path,"w+b")
            at = Base64.decode64(attach)
            t_file.write(Zlib::Inflate.inflate(at))
            t_file.close
            upload = ActionDispatch::Http::UploadedFile.new({
              :filename => name[cnt],
              :content_type => content_type[cnt],
              :size => size[cnt],
              :memo => '',
              :title_id => 1,
              :parent_id => @item.id,
              :content_id => @title.upload_system,
              :db_file_id => 0,
              :tempfile => File.open(t_file.path)
            })

            tmpfile = Gwcircular::File.new({
              :content_type => content_type[cnt],
              :filename => name[cnt],
              :size => size[cnt],
              :memo => '',
              :title_id => 1,
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
    @forward = true

    render action: :new, layout: "admin/template/forward_form"
  end

  def close
    get_role_new
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    @item = Gwcircular::Doc.where(id: params[:id]).first
    return http_error(404) unless @item
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find(params[:id])

    @before_state = @item.state
    @item.attributes = item_params
    @item.state = params[:item][:state]

    time_now = Time.now
    @item.latest_updated_at = time_now

    if @item.target_user_code.blank?
      @item.target_user_code = Core.user.code
      @item.target_user_name = Core.user.name
    end if @gw_admin

    unless @gw_admin
      @item.target_user_code = Core.user.code
      @item.target_user_name = Core.user.name
    end
    update_creater_editor_circular
    @item._commission_count = true
    @item._commission_state = @before_state
    @item._commission_limit = @title.commission_limit

    if @before_state == 'preparation'
      @item.created_at = time_now
    end

    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    s_cond << '&request_path=' + params[:request_path] if params[:request_path].present?
    if @item.state == 'draft'
      if params[:request_path].present?
        location = "#{jgw_circular_path}/close"
      else
        location = "#{jgw_circular_path}#{s_cond}"
      end
    else
      location = "#{jgw_circular_path}/#{@item.id}/circular_publish#{s_cond}"
    end
    _update(@item, notice: params[:message], :success_redirect_uri=>location) if params[:request_path].blank?
    _update(@item, notice: params[:message], :success_redirect_uri=>location,:request_path=>params[:request_path]) if params[:request_path].present?
  end

  def destroy
    @item = Gwcircular::Doc.find(params[:id])
    get_role_edit(@item)
    return authentication_error(403) unless @is_editable
    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    _destroy_plus_location(@item, "#{@title.menus_path}#{s_cond}" )
  end

  def unread_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 1, state: 'unread', target_user_code: Core.user.code)
                          .where(gwcircular_select_status(params))
    if params[:kwd].present?
      item = item.where(search_kwd_cond_parents)
    end
    if params[:creator].present?
      item = item.search_creator(params)
    end
    item = item.search_date(params).order(circular_order)

    @items = item.paginate(page: params[:page]).limit(params[:limit])
    @groups = Gwcircular::Doc.unread_info(@title.id).select_createrdivision_info
    @monthlies = Gwcircular::Doc.unread_info(@title.id).select_monthly_info
  end

  def already_read_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 1, state: 'already', target_user_code: Core.user.code)
                          .where(gwcircular_select_status(params)).search_creator(params)
    if params[:kwd].present?
      item =  item.where(search_kwd_cond_parents)
    end
    item = item.search_date(params).order(circular_order)
    @items = item.paginate(page: params[:page]).limit(params[:limit])
    @groups = Gwcircular::Doc.already_info(@title.id).select_createrdivision_info
    @monthlies = Gwcircular::Doc.already_info(@title.id).select_monthly_info
  end

  def owner_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 0, target_user_code: Core.user.code)
                          .where("state != 'preparation'").where(gwcircular_select_status(params))
    if params[:kwd].present?
      item = item.search_kwd(params)
    end
    if params[:creator].present?
      item = item.search_creator(params)
    end
    item = item.search_date(params).order(circular_order)
    @items = item.paginate(page: params[:page]).limit(params[:limit])
    @groups = Gwcircular::Doc.owner_info(@title.id).select_createrdivision_info
    @monthlies = Gwcircular::Doc.owner_info(@title.id).select_monthly_info
  end

  def commission_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 1, parent_id: @item.id)
                          .where("state != ?", 'preparation').where(gwcircular_select_status(params))
    if params[:kwd].present?
      item = item.search_kwd(params)
    end
    if params[:creator].present?
      item = item.search_creator(params)
    end
    @commissions = item.search_date(params).order("state DESC, id")
  end

  def admin_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 0)
                          .where("state != ?", 'preparation').where(gwcircular_select_status(params))
    if params[:kwd].present?
      item = item.search_kwd(params)
    end
    if params[:creator].present?
      item = item.search_creator(params)
    end
    item = item.search_date(params).order(circular_order)
    @items = item.paginate(page: params[:page]).limit(params[:limit])
    @groups = Gwcircular::Doc.admin_info(@title.id).select_createrdivision_info
    @monthlies = Gwcircular::Doc.admin_info(@title.id).select_monthly_info
  end

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def clone
    item = Gwcircular::Doc.where(id: params[:id]).first
    return http_error(404) unless @item
    get_role_edit(@item)
    clone_doc(@item)
  end

  def circular_publish
    item = Gwcircular::Doc.find_by(id: params[:id])
    return http_error(404) unless item
    item.publish_delivery_data(params[:id])
    item.state = 'public'
    item.save
    s_cond = '?cond=owner'
    s_cond = '?cond=admin' if params[:cond] == 'admin'
    if params[:request_path].present?
      redirect_to "#{jgw_circular_path}/close"
    else
      redirect_to "#{@title.menus_path}#{s_cond}"
    end
  end

  private
  def invalidtoken
    return http_error(404)
  end

  def search_file_index
    file = Gwcircular::File.joins(:parent).where("gwcircular_docs.title_id = #{@title.id}").where(gwcircular_select_status(params))
                           .search(params)
    parentids = Array.new
    case params[:cond]
    when 'unread'
      condition = "state='unread' AND doc_type=1 AND target_user_code='#{Core.user.code}'"
      file = file.order 'gwcircular_docs.expiry_date DESC, gwcircular_docs.id DESC, gwcircular_files.filename'
    when 'already'
      condition = "state='already' AND doc_type=1 AND target_user_code='#{Core.user.code}'"
      file = file.order 'gwcircular_docs.expiry_date DESC, gwcircular_docs.id DESC, gwcircular_files.filename'
    when 'owner', 'void'
      condition = "state!='preparation' AND doc_type=0 AND target_user_code='#{Core.user.code}'"
      file = file.order 'gwcircular_docs.id DESC, gwcircular_files.filename'
      file = file.where("gwcircular_docs.state!='preparation' AND gwcircular_docs.doc_type=0 AND gwcircular_docs.target_user_code='#{Core.user.code}'")
    when 'admin'
      condition = "state!='preparation' AND doc_type=0"
      file = file.order 'gwcircular_docs.id DESC, gwcircular_files.filename'
      file = file.where("gwcircular_docs.state!='preparation' AND gwcircular_docs.doc_type=0")
    else
      condition = "state='unread' AND doc_type=1 AND target_user_code='#{Core.user.code}'"
      file = file.order 'gwcircular_docs.expiry_date DESC, gwcircular_docs.id DESC, gwcircular_files.filename'
    end
    items = Gwcircular::Doc.where(condition)
    items.each do |item|
      parent = Gwcircular::Doc.find_by(id: item.parent_id)
      parentids << parent.id unless parent.blank?
    end
    if parentids.present?
      search_parent_ids = Gw.join([parentids], ',')
      file = file.where("gwcircular_docs.id IN (#{search_parent_ids})")
    elsif parentids.blank? && (params[:cond] == 'unread' || params[:cond] == 'already')
      return @files
    end
    @files = file.paginate(page: params[:page]).limit(params[:limit])
  end

  def search_kwd_cond_parents
    *columns = :title, :body
    cond = ''
    parent = Gwcircular::Doc
    parent = parent.where(title_id: @title.id, doc_type: 0).where("state != 'preparation'")
                   .where(gwcircular_select_status(params))
    parents = parent.search_kwd(params).order('id DESC').select("id")

    cond = "parent_id IN ('')"
    parentids = Array.new
    parents.each do |parent|
      parentids << parent.id unless parent.blank?
    end
    if parentids.present?
      search_parent_ids = Gw.join([parentids], ',')
      cond = "parent_id IN (#{search_parent_ids})"
    end
    return cond
  end

  def circular_order
    case params[:cond]
    when 'unread','already'
      if params[:sort_key].present? && params[:category] == 'DATE'
        item_order = "#{params[:sort_key]} #{params[:order]}, created_at #{params[:order]}"
      elsif params[:sort_key].present? && params[:category] == 'GROUP'
        item_order = "#{params[:sort_key]} #{params[:order]}, createrdivision_id #{params[:order]}, created_at DESC, id #{params[:order]}"
      elsif params[:sort_key].present?
        item_order = "#{params[:sort_key]} #{params[:order]}, id #{params[:order]}"
      elsif params[:category] == 'DATE'
        item_order = "created_at DESC"
      elsif params[:category] == 'GROUP'
        item_order = "createrdivision_id ASC, created_at DESC, expiry_date DESC, id DESC"
      else
        item_order = "created_at DESC, id DESC"
      end
    when 'owner','admin'
      if params[:sort_key].present? && params[:category] == 'DATE'
        item_order = "#{params[:sort_key]} #{params[:order]}, created_at #{params[:order]}"
      elsif params[:sort_key].present? && params[:category] == 'GROUP'
        item_order = "#{params[:sort_key]} #{params[:order]}, createrdivision_id #{params[:order]}, created_at DESC, id #{params[:order]}"
      elsif params[:sort_key].present?
        item_order = "#{params[:sort_key]} #{params[:order]}, id #{params[:order]}"
      elsif params[:category] == 'DATE'
        item_order = "created_at DESC"
      elsif params[:category] == 'GROUP'
        item_order = "createrdivision_id ASC, created_at DESC, id DESC"
      elsif params[:category] == 'EXPIRY'
        item_order = "expiry_date DESC, created_at DESC, id DESC"
      else
        item_order = "created_at DESC, id DESC"
      end
    else
      if params[:sort_key].present? && params[:category] == 'DATE'
        item_order = "#{params[:sort_key]} #{params[:order]}, created_at #{params[:order]}"
      elsif params[:sort_key].present? && params[:category] == 'GROUP'
        item_order = "#{params[:sort_key]} #{params[:order]}, createrdivision_id #{params[:order]}, id #{params[:order]}"
      elsif params[:sort_key].present?
        item_order = "#{params[:sort_key]} #{params[:order]}, id #{params[:order]}"
      elsif params[:category] == 'DATE'
        item_order = "created_at DESC"
      elsif params[:category] == 'GROUP'
        item_order = "createrdivision_id ASC, created_at DESC, expiry_date DESC, id DESC"
      else
        item_order = "created_at DESC, id DESC"
      end
    end
    return item_order
  end

  def all_download
    require "mail"

    mail = Mail.new
    to = []

    JsonParser.new.parse(@item.reader_groups_json).each do |reader|
      to << reader[2] + " <enisys>"
    end
    JsonParser.new.parse(@item.readers_json).each do |reader|
      to << reader[2] + " <enisys>"
    end
    mail.to = to

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
    filename = "#{URI::escape("(#{@piece_head_title})")}_#{@item.created_at.strftime('%Y%m%d')}_#{title}.eml"
    send_data(mail.to_s, :filename => filename,
        :type => 'message/rfc822', :disposition => 'attachment')
  end

  def item_params
    params.require(:item)
          .permit(:title, :body, :state, :confirmation, :spec_config, :expiry_date, :importance, :reader_groups_json, :readers_json)
  end

protected

  def select_layout
    layout = "admin/template/portal"
    case params[:action].to_sym
    when :gwbbs_forward, :mail_forward
      layout = "admin/template/forward_form"
    end
    layout
  end
end

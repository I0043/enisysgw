# -*- encoding: utf-8 -*-
class Gwcircular::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize
  include Gwcircular::DocsHelper
  layout :select_layout
  require 'base64'
  require 'zlib'

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    Page.title = t('rumi.circular.name')
    @piece_head_title = t('rumi.circular.name')
    @side = "gwcircular"

    s_cond = ''
    s_cond = "?cond=#{params[:cond]}" unless params[:cond].blank?
    return redirect_to("#{gwcircular_menus_path}#{s_cond}") if params[:reset]

    params[:limit] = @title.default_limit unless @title.default_limit.blank?
    unless params[:id].blank? or params[:rid].present?
      item = Gwcircular::Doc.find(params[:id])
      unless item.blank?
        if item.doc_type == 0
          params[:cond] = 'owner'
        end
        if item.doc_type == 1
          params[:cond] = 'unread' if item.state == 'unread'
          params[:cond] = 'already' if item.state == 'already'
        end
      end
    end
    
    get_piece_menus
  end

  def index
    redirect_to "#{@title.item_home_path}"
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    @item = Gwcircular::Doc.where(id: params[:id]).where("state != ?", 'preparation').first
    return http_error(404) if @item.blank?

    get_role_show(@item)  #admin, readable, editable
    @is_readable = false unless @item.target_user_code == Site.user.code unless @gw_admin
    return authentication_error(403) unless @is_readable

    if @item.state == 'unread'
      @item.state = 'already'
      @item.published_at = Time.now
      @item.latest_updated_at = Time.now
      update_creater_editor_circular
      @item._commission_count = true
      @item.save
      params[:cond] = 'already'
    end unless @item.confirmation == 1

    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)
    return http_error(404) unless @parent

    # 添付ファイルの取得
    @files = Gwcircular::File.where(:parent_id => @parent.id)

    commission_index

    return all_download if params[:download]=='full_download'
    return download unless params[:download].blank?
  end

  def gwbbs_forward
    @item = Gwcircular::Doc.where(id: params[:id]).where("state != ?", 'preparation').first
    return http_error(404) if @item.blank?

    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)
    return http_error(404) unless @parent

    @forward_form_url = "/gwbbs/forward_select"
    @target_name = "gwbbs_form_select"
    forward_setting
  end

  def mail_forward
    @item = Gwcircular::Doc.where(id: params[:id]).where("state != ?", 'preparation').first
    return http_error(404) if @item.blank?

    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)
    return http_error(404) unless @parent

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
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.title') + " " + ERB::Util.html_escape(@parent.title) + "<br />"
    #本文_作成日時
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.create_date') + " " + (I18n.l @parent.created_at).to_s + "<br />"
    #本文_作成者
    @gwcircular_text_body << I18n.t('rumi.message.forward_message.gwcircular.creator') + " " + @parent.createrdivision + " " + @parent.creater + "<br />"
    #本文_回覧記事本文
    @gwcircular_text_body << @parent.body
    @gwcircular_text_body = Base64.encode64(@gwcircular_text_body).split().join()

    @tmp = ""
    @name = ""
    @content_type = ""
    @size = ""

    forward = Gwcircular::Doc.find_by(id: @parent.id)
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

  def commission_index(no_paginate=nil)
    item = Gwcircular::Doc.where(title_id: @title.id, doc_type: 1, parent_id: @item.parent_id)
                          .where("state != ?", 'preparation').where("target_user_code != ?", Site.user.code)
    if params[:kwd].present?
      item = item.where(search_kwd_cond_parents)
    end
    if params[:creator].present?
      item = item.search_creator(params)
    end
    @commissions = item.search_date(params)
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    @item = Gwcircular::Doc.where(id: params[:id]).where("state != ?", 'preparation').first
    return http_error(404) unless @item
    get_role_edit(@item)

    @is_readable = false unless @item.target_user_code == Site.user.code unless @gw_admin
    return authentication_error(403) unless @is_editable
    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)
    return http_error(404) unless @parent
  end

  def edit_show
    get_role_new
    return authentication_error(403) unless @is_writable

    @item = Gwcircular::Doc.where(id: params[:id]).where("state != ?", 'preparation').first

    return http_error(404) unless @item
    get_role_edit(@item)

    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)
    return http_error(404) unless @parent

    @is_read_show = false
    return http_error(404) if params[:rid].blank?
    @myitem = Gwcircular::Doc.where(title_id: 1, id: params[:rid]).first
    commissions = Gwcircular::Doc.where("state != ?", 'preparation').where(title_id: 1, parent_id: @parent.id)
    commissions.each do |commission|
      @is_read_show = true if commission.target_user_code == Site.user.code and commission.is_readable_edit_show?
    end
    @is_read_show = true if @gw_admin or @parent.target_user_code == Site.user.code
    return authentication_error(403) unless @is_read_show

    # 添付ファイルの取得
    @files = Gwcircular::File.where(:parent_id => @item.id)
  end

  def update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find_by(id: params[:id])
    return http_error(404) unless @item

    @parent = Gwcircular::Doc.find_by(id: @item.parent_id)

    @is_writable = false unless @item.target_user_code == Site.user.code unless @gw_admin
    return authentication_error(403) unless @is_writable

    @before_state = @item.state
    @item.attributes = item_params
    if @before_state == 'unread'
      @item.published_at = Time.now
    end if @item.published_at.blank?

    @item.latest_updated_at = Time.now
    update_creater_editor_circular
    @item._commission_count = true
    location = "#{@item.show_path}?cond=#{params[:cond]}"

    _update(@item, :success_redirect_uri=>location, notice: t("rumi.message.notice.create"))
  end

  def already_update
    get_role_new
    return authentication_error(403) unless @is_writable
    @item = Gwcircular::Doc.find_by(id: params[:id])
    return http_error(404) unless @item

    @is_writable = false unless @item.target_user_code == Site.user.code unless @gw_admin
    return authentication_error(403) unless @is_writable
    @item.state = 'already'
    @item.latest_updated_at = Time.now
    @item.published_at = Time.now
    update_creater_editor_circular
    @item._commission_count = true
    @item.save

    # 新着情報を既読に変更
    @item.parent_doc.seen_remind(Site.user.id)

    location = "#{@item.show_path}?cond=already"
    redirect_to location
  rescue ActiveRecord::StatementInvalid => e
    case e.message
    when /Lock wait timeout exceeded/
      raise I18n.t('rumi.gwcircular.message.already_update_error')
    else
      raise e.message
    end
  end

  def all_download
    require "mail"

    mail = Mail.new
    to = []

    if @parent.spec_config.to_i != 0
      JsonParser.new.parse(@parent.reader_groups_json).each do |reader|
        to << reader[2] + " <enisys>"
      end
      JsonParser.new.parse(@parent.readers_json).each do |reader|
        to << reader[2] + " <enisys>"
      end
    end
    mail.to = to

    mail.from    = @parent.editor.present? ? @parent.editor.to_s : @parent.creater.to_s
    mail.subject = @parent.title.to_s

    mail_body = @parent.body
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

    title = @parent.title.gsub(/[\/\<\>\|:;"\?\*\\\r\n]/, '_')
    title = title.match(/^.{100}/).to_s if title.length > 100
    title = URI::escape(title)
    filename = "#{URI::escape("(#{@piece_head_title})")}_#{@parent.created_at.strftime('%Y%m%d')}_#{title}.eml"
    send_data(mail.to_s, :filename => filename,
        :type => 'message/rfc822', :disposition => 'attachment')
  end

  def download
    unless File.exist?(Rumi::Gwcircular::ZipFileUtils::TMP_FILE_PATH)
      FileUtils.mkdir_p(Rumi::Gwcircular::ZipFileUtils::TMP_FILE_PATH)
    end

    zip_data = {}
    for attache_file in @files
      # zipファイル情報の保存
      zip_data["#{attache_file.filename}"] =
        attache_file.f_name
    end

    target_zip_file = File.join(
        Rumi::Gwcircular::ZipFileUtils::TMP_FILE_PATH,
        "#{request.session_options[:id]}.zip")

    Rumi::Gwcircular::ZipFileUtils.zip(
        target_zip_file,
        zip_data,
        {:fs_encoding => Rumi::Gwcircular::ZipFileUtils::ZIP_ENCODING})

    title = @item.title.gsub(/[\/\<\>\|:;"\?\*\\\r\n]/, '_')
    title = title.match(/^.{100}/).to_s if title.length > 100
    title = URI::escape(title)
    circular_head_name = I18n.t('rumi.gwcircular.download.tmpfile')
    filename = "#{URI::escape("(#{circular_head_name})")}_#{@item.created_at.strftime('%Y%m%d')}_#{title}.zip"
    send_file target_zip_file ,
        :filename => filename if FileTest.exist?(target_zip_file)
  end

  private
  def invalidtoken
    return http_error(404)
  end

  def item_params
    params.require(:item)
          .permit(:body, :state)
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

# encoding: utf-8
class ApplicationController < ActionController::Base
###  include Cms::Controller::Public
#  include Jpmobile::ViewSelector
  helper  FormHelper
  helper  LinkHelper
  include RumiHelper
  protect_from_forgery #:secret => '1f0d667235154ecf25eaf90055d99e99'
  before_action :initialize_core
  before_action :initialize_application, :logging_action, :get_header, :get_link_piece, :get_today, :is_admin

  def initialize_application
    return true
  end

  def initialize_core
    return if Core.dispatched?
    return Core.dispatched
  end
  
  def logging_action
    remote_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
    params[:url] = request.path_info
    access_log = System::AccessLog.new(user_id: Core.user.try(:id), user_code: Core.user.try(:code),
      user_name: Core.user.try(:name), ipaddress: remote_ip, controller_name: controller_name,
      action_name: action_name, parameters: params, feature_id: params[:url])
    access_log.save if access_log.logging?(params)
    return true
  end

  def get_header
    begin
      is_admin
      get_header_menus
      get_smart_header_menus
    rescue => e
      Rails.logger.info e
    end
  end

  def get_link_piece
    @edit_link_piece_items = Gw::EditLinkPiece.where(state: "enabled", level_no: 4).order(:sort_no)
  end

  def get_today
    @today = I18n.l Time.now.to_date, format: :date1
    @calender_date_select_format = t("rumi.calender_date_select.format_js")
    @calender_date_select_locale = t("rumi.calender_date_select.locale_js")
  end
  
  def is_admin
    if Core.user.present?
      roles = System::Role.where(table_name: '_admin', uid: Core.user.id).first
      @gw_admin = roles.present? ? true : false
    end
  end

  def get_side_schedule_menu
    @side_prop_group = []
    @type = Gw::PropType.where(state: 'public').order(:sort_no, :id).select("id, name")
    @group = Gw::PropGroup.where(state: 'public').where("id > ?", '1').where(parent_id: '1').order(:sort_no)
    @child = Gw::PropGroup.where(state: 'public').where("parent_id > ?", '1').order(:sort_no)

    @group.each do |group|
      @side_prop_group << group
      @child.each do |child|
        if child.parent_id == group.id
          @side_prop_group << child
        end
      end
    end

    ug = Core.user.user_group_parent_ids
    
    cg_roles = System::CustomGroupRole.where(class_id: 1, user_id: Core.user.id, priv_name: 'read').map(&:custom_group_id)
    cg_roles << System::CustomGroupRole.where(class_id: 2, group_id: ug, priv_name: 'read').map(&:custom_group_id)
    cg_roles << System::CustomGroupRole.where(class_id: 2, group_id: 0, priv_name: 'read').map(&:custom_group_id)
    @side_cg = System::CustomGroup.where(state: "enabled", id: cg_roles.flatten.uniq)
                                  .order("owner_uid = #{Core.user.id} desc")
                                  .order(:sort_prefix, :sort_no)

    @side_prop_type = Gw::PropType.where(state: "public")
                                  .order(:sort_no)
  end

  def skip_layout
    self.class.layout 'base'
  end

  def query(params = nil)
    Util::Http::QueryString.get_query(params)
  end

  def send_mail(mail_fr, mail_to, subject, message)
    return false if mail_fr.blank?
    return false if mail_to.blank?
    Sys::Lib::Mail::Base.deliver_default(mail_fr, mail_to, subject, message)
  end

  # === レコード状況を返すメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  現在のレコード状況
  def record_inspect_changed(errors_record)
    msg_delimiter = ", "
    errors_record_class_name = errors_record.class.name
    errors_record_changed = errors_record.changed || []
    was_values = (errors_record_changed.map { |change_column_name| errors_record.send("#{change_column_name}_was").inspect }).join(msg_delimiter)

    msg = ["[INSPECT DEBUG INFO START] #{errors_record_class_name}"]
    msg << "[ERRORS FULL_MESSAGES] #{errors_record.errors.full_messages.join(msg_delimiter)}"
    msg << "[INSPECT] #{errors_record.inspect}"
    msg << "[CHANGED LIST] #{errors_record_changed.join(msg_delimiter)}"
    msg << "[WAS VALUES] #{was_values}"
    msg << errors_record.inspect_associations_info if errors_record.respond_to?(:inspect_associations_info)
    msg << ["[INSPECT DEBUG INFO END] #{errors_record_class_name}"]

    return msg.join("\n")
  end

  def tamtam_css(body)
    css = ''
    body.scan(/<link [^>]*?rel="stylesheet"[^>]*?>/i) do |m|
      css += %Q(@import "#{m.gsub(/.*href="(.*?)".*/, '\1')}";\n)
    end
    4.times do
      css = convert_css_for_tamtam(css)
    end
    css.gsub!(/^@.*/, '')
    css.gsub!(/[a-z]:after/i, '-after')
    css
  end

  def convert_css_for_tamtam(css)
    css.gsub(/^@import .*/) do |m|
      path = m.gsub(/^@import ['"](.*?)['"];/, '\1').gsub(/([^\?]+)\?.[^\?]+/, '\1')
      dir  = (path =~ /^\/_common\//) ? Rails.root.join("public") : Rails.root.join("public")
      file = "#{dir}#{path}"
      if FileTest.exist?(file)
        m = ::File.new(file).read.gsub(/(\r\n|\n|\r)/, "\n").gsub(/^@import ['"](.*?)['"];/) do |m2|
          p = m2.gsub(/.*?["'](.*?)["'].*/, '\1')
          p = ::File.expand_path(p, ::File.dirname(path)) if p =~ /^\./
          %Q(@import "#{p}";)
        end
      else
        m = ''
      end
      m.gsub!(/url\(\.\/(.+)\);/, "url(#{File.dirname(path)}/\\1);")
      m
    end
  end

private
  def rescue_exception(exception)
    Core.terminate

    log  = exception.to_s
    log += "\n" + exception.backtrace.join("\n") if Rails.env.to_s == 'production'
    error_log(log)

    html  = %Q(<div style="padding: 15px 20px; color: #e00; font-weight: bold; line-height: 1.8;">)
    case
    when exception.is_a?(Mysql2::Error)
      html += %Q(データベースへの接続に失敗しました。<br />#{exception} &lt;#{exception.class}&gt;)
    else
      html += %Q(error! <br />#{exception} &lt;#{exception.class}&gt;)
    end
    html += %Q(</div>)
    if Rails.env.to_s != 'production'
      html += %Q(<div style="padding: 15px 20px; border-top: 1px solid #ccc; color: #800; line-height: 1.4;">)
      html += exception.backtrace.join("<br />")
      html += %Q(</div>)
    end
    
    render :inline => html, :layout => true, :status => 500
  end

  def rescue_action(error)
    case error
    when ActionController::InvalidAuthenticityToken
      http_error(422, error.to_s)
    else
      Core.terminate
      super
    end
  end

  ## Production && local
  def rescue_action_in_public(exception)
    #exception.each{}
    http_error(500, nil)
  end

  def http_error(status, message = nil)
    Core.terminate

    ## errors.log
    if status != 404
      request_uri = request.fullpath.force_encoding('UTF-8')
      error_log("#{status} #{request_uri} #{message.to_s.gsub(/\n/, ' ')}")
    end

    ## Render
    file = "#{Rails.public_path}/500.html"
    if FileTest.exist?("#{Rails.public_path}/#{status}.html")
      file = "#{Rails.public_path}/#{status}.html"
    end

    @message = message
    return respond_to do |format|
      format.html { render(:status => status, :file => file, :layout => false) }
      format.xml  { render :xml => "<errors><error>#{status} #{message}</error></errors>" }
    end
  end

  def flash_notice(action_description = '処理', done = nil, mode=nil)
    ret = action_description + 'に' + ( done ? '成功' : '失敗' ) + 'しました'
    if mode.blank?
      flash[:notice] = ret
    else
      return ret
    end
  end

  def authentication_error(code=403 ,message=nil)
    Page.error = code

    f = File.open(Rails.root.join("log", code.to_s + ".log"), 'a')
    f.flock(File::LOCK_EX)
    f.puts "\n" + '====================='
    f.puts Time.now.strftime(' %Y-%m-%d %H:%M:%S') + "\n\n"
    f.puts request.env["REQUEST_URI"]
    f.puts "\n" + '====================='
    f.flock(File::LOCK_UN)
    f.close

    error_file = Rails.root.join("public/500.html")
    if FileTest.exist?(Rails.root.join("public/#{code.to_s}.html"))
      error_file = Rails.root.join("public/#{code.to_s}.html")
    end

    @message = message
    return respond_to do |format|
      format.html { render(:status => code, :file => error_file, :layout => false) }
      format.xml  { render :xml => "<errors><error>#{code} #{message}</error></errors>" }
    end
  end
end

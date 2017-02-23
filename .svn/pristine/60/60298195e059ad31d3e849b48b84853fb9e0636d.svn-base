# encoding: utf-8
class Gw::Admin::LinkSsoController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout 'base'

  def index

  end

 def redirect_to_plus
    plus_uri = Gw::UserProperty.where("class_id = ? AND name = ? ",3,"plus_sso").first
    host = ""
    host = plus_uri.options unless plus_uri.blank?
    pass = Core.user.password
    para = CGI.escape(pass)
    require 'net/http'
    Net::HTTP.version_1_2
    plus_use_ssl = Gw::UserProperty.where("class_id = ? AND name = ? and options = ?",3,"plus_ssl","true").first
    if plus_use_ssl.blank?
      sso_use_ssl = false
    else
      sso_use_ssl = true
    end
    if sso_use_ssl == true
      http     = Net::HTTP.new(host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http_prefix = "https://"
    else
      http = Net::HTTP.new(host, 80)
      http_prefix = "http://"
    end

    res      = http.post("/_admin/air_sso", "account=#{Core.user.code}&password=#{para}")
    token    = (res.body.to_s =~ /^OK/i) ? res.body.to_s.gsub(/^OK /i, '') : nil
    next_uri = "#{http_prefix}#{host}/_admin/air_sso?account=#{Core.user.code}&token=#{token}"
    next_uri += "&path=#{params[:path]}" unless params[:path].blank?

    return redirect_to next_uri
  end

  def redirect_pref_pieces
    id = params[:id]
    raise Gw::SystemError, t("rumi.message.incorrect_call") if !Gw.int?(id)

    id = id.to_i
    if params[:src] == 'tab'
      item = Gw::EditTab.find_by(id: id)
    else
      item = Gw::EditLinkPiece.find_by(id: id)
    end
    raise Gw::SystemError, t("rumi.message.incorrect_call") if item.blank?

    check_name = t("rumi.mail.name")
    if item.name == check_name or  params[:id].to_i==64 or params[:id].to_i==65
      redirect_page = redirect_page_mail(item.link_url, item.field_account, item.field_pass)
    else
      redirect_page = redirect_page_create(item.link_url, item.field_account, item.field_pass)
    end
    render :text => redirect_page
  end

  # === メール閲覧画面へのシングル・サインオン対応アクション
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  認証成功: メール閲覧画面 / 認証失敗: authentication_error(403)
  def redirect_rumi_mail
    @next_uri = Rumi::WebmailApi.new.login(Core.user.code, Core.user.password, params[:path] || "/")
    authentication_error(403) unless @next_uri
  end

private

  def redirect_page_create(url, field_account, field_pass)

    redirect_page = <<-EOL
<html>
<head>
<meta http-equiv="Content-Language" content="ja">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Expires" content="-1">
<title>redirect</title>
<!--JavaScript-->
<script language="JavaScript">
<!--
function PostToAuth(){
  document.loginform.submit();
}
-->
</script>
</head>
<body onLoad="PostToAuth();">
<form name="loginform" action="#{url}" method="post" >
<input type="hidden" name="#{field_account}" value="#{Core.user.code}">
<input type="hidden" name="#{field_pass}" value="#{Core.user.password}">
</form>
</body>
</html>
EOL

    return redirect_page
  end

  def redirect_page_mail(host, field_account, field_pass)
    uri_base = host
    _url = uri_base.split(':')
    host = _url[0]
    port = _url[1].nil? ? '80' : _url[1]

    pass = Core.user.password
    para = CGI.escape(pass)
    require 'net/http'
    Net::HTTP.version_1_2
    http     = Net::HTTP.new(host, port)
    res      = http.post("/_admin/air_sso", "account=#{Core.user.code}&password=#{para}")
    token    = (res.body.to_s =~ /^OK/i) ? res.body.to_s.gsub(/^OK /i, '') : nil
    next_uri = "http://#{uri_base}/_admin/air_sso?account=#{Core.user.code}&token=#{token}"

    title = t("rumi.mail.name")
    error_message_head = t("rumi.mail.error_message_head")
    error_message_tail = t("rumi.mail.error_message_tail")
    redirect_page = <<-EOL
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<meta http-equiv="Content-Language" content="ja">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Expires" content="-1">
<title>#{title}</title>
EOL

    if token
      redirect_page += %Q(<script type="text/javascript">\n//<![CDATA[\n)
      redirect_page += %Q(location.href = "#{next_uri}";\n)
      redirect_page += %Q(//]]>\n</script>\n)
    end

    redirect_page += %Q(</head><body>\n)

    if token.nil?
      redirect_page += %Q(<div>\n)
      redirect_page += %Q(#{error_message_head}<br />#{error_message_tail}<br />\n)
      redirect_page += %Q(</div>\n)
    end

    redirect_page += %Q(</body></html>\n)

    return redirect_page
  end
end

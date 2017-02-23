# encoding: utf-8
module Sys::Controller::Admin::Auth
  ACCOUNT_KEY = :sys_user_account
  PASSWD_KEY  = :sys_user_password
  @@current_user = false

protected
  def logged_in?
    if session[:expired_at] && session[:expired_at] < Time.now
      reset_session
      return false
    end
    return false unless session[:sys_user_account]

    expiration = Enisys.config.application['sys.session_expiration']

    session[:expired_at] = Time.now + expiration.hours
    current_user != false
  end

  def new_login(_account, _password)
    unless user = System::User.authenticate(_account, _password)
      flash.now[:notice] = I18n.t("rumi.login.message.login_fail")
      return false
    end
    if user.enable_user_groups.length == 0
      flash.now[:notice] = I18n.t("rumi.account.group_error_head") + I18n.t("rumi.account.group_error_tail")
      return false
    end
    session[ACCOUNT_KEY]  = user.code
    session[PASSWD_KEY] = user.encrypt_password
    System::LoginLog.put_log(user)
    @@current_user = user
  end

  def set_current_user(user)
    @@current_user = user

    session[ACCOUNT_KEY] = user.code
    session[PASSWD_KEY] = user.encrypt_password

    System::LoginLog.put_log(user)
  end

  def current_user
    return @@current_user if @@current_user
    return false if (!session[ACCOUNT_KEY] || !session[PASSWD_KEY])
    unless user = System::User.authenticate(session[ACCOUNT_KEY], session[PASSWD_KEY], true)
      return false
    end
    @@current_user = user
  end

  def authorized?
    true
  end

  def login_required
    username, passwd = get_auth_data
    self.current_user ||= System::User.authenticate(username, passwd) || :false if username && passwd
    logged_in? && authorized? ? true : access_denied
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/account', :action => 'login'
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  def self.included(base)
  end

  def login_from_cookie
    return unless cookies[:auth_token] && !logged_in?
    user = System::User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      self.current_user = user
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      flash.now[:notice] = "Logged in successfully"
    end
  end

private
  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  # gets BASIC auth info
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
  end
end

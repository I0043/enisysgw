# coding: utf-8

class System::AccessLog < ActiveRecord::Base

  default_scope -> { order(:created_at) }

  scope :extract_start_date, lambda {|start_date|
    where('created_at >= ?', start_date)
  }

  scope :extract_end_date, lambda {|end_date|
    where('created_at <= ?', end_date)
    .order('created_at desc')
  }

  scope :extract_date, lambda {|start_date, end_date|
    where('created_at >= ? and created_at <= ?', start_date, end_date)
    .order('created_at')
  }

  scope :extract_csv_date, lambda {|start_date, end_date,data_cnt|
    where('created_at >= ? and created_at <= ?', start_date, end_date)
    .order('created_at')
    .limit(data_cnt)
  }

  before_create :before_create_record

  FEATURE_NAMES = {
    account: {
      login: I18n.t("rumi.access_log.category.login"),
      logout: I18n.t("rumi.access_log.category.logout")
    }
  }

  def logging?(params)
    to_feature_id(params).present?
  end

  def to_feature_id(params = nil)
    f_id = nil

    params_controller = params.present? ? params[:controller] : self.controller_name
    params_url = params.present? ? params[:url] : self.feature_id
    params_action = params.present? ? params[:action] : self.action_name

    #ログアウトしログインし直した場合等のURL変化対応
    params_url = '/' if params_url == '/gw/portal'

    #リンクピースから固定ヘッダー部のurl及び機能名を取得
    mail_name = I18n.t("rumi.mail.name")
    header_urls = Gw::EditLinkPiece.select("link_url,name")
                                   .where(state: "enabled", level_no: 3)
                                   .where.not(name: mail_name)
                                   .where.not(link_url: "")
                                   .order("sort_no")

    header_urls.each do |h_url|
      #アクセスログ用の機能名に対するID及び機能名の保存
      id = h_url.link_url.split('?')
      FEATURE_NAMES[id[0].to_sym] = h_url.name
    end

    if params_controller.include?('account')
      #ログインもしくはログアウト
      login_key = 'login'
      logout_key = 'logout'

      f_id = login_key if params_action.include?(login_key) &&
                          (self.parameters["account"].present?)
      f_id = logout_key if params_action.include?(logout_key)
    else
      #その他
      FEATURE_NAMES.keys.each do |key|
        f_id = key if params_url == key.to_s
      end

      f_id = nil unless params_action == 'index' || params_action == 'show_week'
    end

    #タブで切り替える部分のパラメータ判断によるログ取得却下
    if params.present?
      f_id = nil if params[:cond].present?  #回覧板のタブ切り替えで使用
      f_id = nil if params[:cgid].present?  #スケジュールのグループ週表示で使用
      f_id = nil if params[:c1].present?  #設定の管理者設定のタブ切り替えで使用
    end

    return f_id.to_s
  end

  def to_feature_name
    feature = feature_id
    feature = '/' if feature == '/gw/portal'
    return FEATURE_NAMES[:account][:login] if feature.include?('login')
    return FEATURE_NAMES[:account][:logout] if feature.include?('logout')
    return FEATURE_NAMES[feature.to_sym]
  end

  def before_create_record
    set_feature_info
    set_login_user_info
  end

  def set_feature_info
    self.feature_name = to_feature_name
  end

  def set_login_user_info
    if feature_id == 'login'
      user_code = self.parameters[:account]
      @user = System::User.find_by_code(user_code) if user_code.present?
      user = System::User.authenticate(parameters["account"], parameters["password"])

      self.user_code = user_code
      self.user_id = @user.try(:id)

      self.user_name = @user.try(:name) if user
      self.user_name = '' unless user
    end
  end
end

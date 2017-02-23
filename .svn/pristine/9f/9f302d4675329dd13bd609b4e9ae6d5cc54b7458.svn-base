# encoding: utf-8
class Gw::Admin::SmartPortalController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include RumiHelper
  layout "admin/template/smart_portal"

  def initialize_scaffold
    Page.title = I18n.t("rumi.top_page.name")
  end

  def index
    # ヘッダーメニュー
    user_id = current_user.id
    count = Gw::Schedule.normal_notification(user_id) + Gw::Schedule.prop_notification(user_id)
    if count.zero?
      @header_count = ""
    else
      count = "99+" if count > 99
      @header_count = "<span>#{count}</span>".html_safe
    end
    # メッセージ
    @admin_message_items  = Gw::AdminMessage.where(state: 1)
                              .order('state ASC , sort_no ASC , updated_at DESC')
                              .limit(2)

    get_reminder
    session[:request_fullpath] = request.fullpath
  end

  def get_reminder
    @user_id = Core.user.id if @user_id.blank?
    [:user_id, :code, :name, :group_code, :group_name]
      .each {|key| instance_variable_set("@#{key}", params[key]) }

    # 並び順
    sort_key = params[:sort_key] == "title" ? "title" : "datetime"
    order = params[:order] == "asc" ? "asc" : "desc"

    # 新着情報
    @reminders = {}
    # 固定ヘッダーアイコン
    header_menus = Gw::EditLinkPiece.extract_location_header.map { |header_menu| header_menu.opened_children.to_a }
    header_menus.flatten!

    # 回覧板
    @user_id = Core.user.id if @user_id.blank?
    circular_remind = Gwcircular::Control.remind(@user_id, sort_key, order)
    circular_menu = (header_menus.select { |header_menu| circular_feature_url?(header_menu.link_options[:url]) }).first
    if circular_remind.present? && circular_menu.present?
      circular_remind.store(:title, circular_menu.name)
      circular_remind.store(:url, circular_menu.link_options[:url])
      circular_remind.store(:div_class, "bg-orange")
      @reminders.store(:circular, circular_remind)
    end

    # 掲示板
    @user_id = Core.user.id if @user_id.blank?
    bbs_remind = Gwbbs::Control.remind(@user_id, sort_key, order)
    bbs_menu = (header_menus.select { |header_menu| bbs_feature_url?(header_menu.link_options[:url]) }).first
    if bbs_remind.present? && bbs_menu.present?
      bbs_remind.store(:title, bbs_menu.name)
      bbs_remind.store(:url, bbs_menu.link_options[:url])
      bbs_remind.store(:div_class, "bg-orange")
      @reminders.store(:bbs, bbs_remind)
    end

    # スケジュール・施設予約
    @user_id = Core.user.id if @user_id.blank?
    schedule_remind = Gw::Schedule.remind(@user_id, sort_key, order)
    schedule_menu = (header_menus.select { |header_menu| schedule_feature_url?(header_menu.link_options[:url]) }).first
    schedule_prop_menu = (header_menus.select { |header_menu| schedule_prop_feature_url?(header_menu.link_options[:url]) }).first
    if schedule_remind.present? && (schedule_menu.present? || schedule_prop_menu.present?)
      schedule_title = []
      schedule_url = []
      if schedule_menu.present?
        schedule_title << schedule_menu.name
        _url = schedule_menu.link_options[:url].split('/')
        url = "/" + _url[1] + "/smart_" + _url[2]
        schedule_url << url
      end
      if schedule_menu.present? && schedule_prop_menu.present?
        schedule_title << I18n.t("rumi.reminder.delimiter")
        schedule_url << nil
      end
      if schedule_prop_menu.present?
        schedule_title << schedule_prop_menu.name
        _url = schedule_prop_menu.link_options[:url].split('/')
        url = "/" + _url[1] + "/smart_" + _url[2]
        schedule_url << url
      end

      schedule_remind.store(:title, schedule_title)
      schedule_remind.store(:url, schedule_url)
      schedule_remind.store(:div_class, "bg-red")
      @reminders.store(:schedule, schedule_remind)
    end

    # ファイル管理
    doclibrary_remind = Doclibrary::Control.remind(@user_id, sort_key, order)
    doclibrary_menu = (header_menus.select { |header_menu| doclibrary_feature_url?(header_menu.link_options[:url]) }).first
    if doclibrary_remind.present? && doclibrary_menu.present?
      doclibrary_remind.store(:title, doclibrary_menu.name)
      doclibrary_remind.store(:url, doclibrary_menu.link_options[:url])
      doclibrary_remind.store(:div_class, "bg-brown")
      @reminders.store(:doclibrary, doclibrary_remind)
    end

    @all_seen_category = ["schedule","schedule_prop","bbs","circular"]
  end
end

# encoding: utf-8
class Gw::Admin::AccessLogsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout "admin/template/portal"

  require 'csv'

  def initialize_scaffold
    Page.title = t("rumi.access_log.name")
    @piece_head_title = t("rumi.access_log.name")
    @side = "setting"
    
    @admin_role = Gw.is_admin_admin?
    return http_error(403) unless @gw_admin
    
    params[:limit] = nz(params[:limit], 30)
  end

  def index
    now = Time.now
    if params[:item].blank?
      start_min = (now.min / 5) * 5
      @start_date = Time.local(now.year, now.month, now.day, now.hour, start_min)
      @end_date = @start_date + 5.minutes
      @s_date = I18n.l @start_date, format: :time2
      @e_date = I18n.l @end_date, format: :time2
    else

      @case = '0'
      if params[:item]['st_at(4i)'] =~ /^[0-9]+$/
        @case += '1'
      end
      if params[:item]['st_at(5i)'] =~ /^[0-9]+$/
        @case += '2'
      end
      if params[:item]['ed_at(4i)'] =~ /^[0-9]+$/
        @case += '3'
      end
      if params[:item]['ed_at(5i)'] =~ /^[0-9]+$/
        @case += '4'
      end

      #絞込日に文字が入っている場合の考慮
      if @case != '01234'
        start_min = (now.min / 5) * 5
        @start_date = Time.local(now.year, now.month, now.day, now.hour, start_min)
        @end_date = @start_date + 5.minutes
        @s_date = I18n.l @start_date, format: :time2
        @e_date = I18n.l @end_date, format: :time2
      else
        @start_date = params[:item][:st_at].to_time
        @s_date = I18n.l @start_date, format: :time2
        @end_date =  params[:item][:ed_at].to_time
        @e_date = I18n.l @end_date, format: :time2
      end
    end

    #絞込日時範囲内のログ取得
    @logs = System::AccessLog.extract_date(@start_date.strftime("%Y-%m-%-d %-H:%-M"), @end_date.strftime("%Y-%m-%-d %-H:%-M"))

    #固定ヘッダーの情報取得
    categories = Gw::EditLinkPiece.extract_location_header

    # ログデータ取得
    categories_data = @logs.group(:feature_name).count

    @categories =[]  #グラフ表示用機能名
    @data = []  #グラフデータ

    #固定ヘッダーに存在する機能名のログ集計
    categories.each do |categories|
      categories.opened_children.each_with_index do |level3_item, idx3|
        next if level3_item.published != 'opened' || level3_item.state != 'enabled'
        category = level3_item.name
        @categories << category
        @data << categories_data.delete(category)
      end
    end

    #ログイン情報の集計
    @categories << t("rumi.access_log.category.login")
    @data << categories_data.delete(t("rumi.access_log.category.login"))

    #ログアウト情報の集計
    @categories << t("rumi.access_log.category.logout")
    @data << categories_data.delete(t("rumi.access_log.category.logout"))

    #固定ヘッダーに存在しない機能名のログ集計
    categories_data.each do |category, data|
      @categories << category
      @data << data
    end

    @data_cnt = @logs.count

    #機能別の最大値取得
    max = @data.compact.max || 0
    
    @column_graph = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "column")
      f.title(:text => "#{I18n.l @start_date, format: :time1} #{t("rumi.access_log.at")} #{I18n.l @end_date, format: :time1}")
      f.xAxis(:categories => @categories)
#機能別の最大値が5件未満であれば縦軸最大値を固定する
      if max < 5
        f.yAxis(:max => "5",
                :allowDecimals => "false",
                :title => {
                  :align => "middle",
                  :text => "　"
                })
      end
      f.series(:name => t("rumi.access_log.functional_access"),
               :data => @data,
               :dataLabels => {
                 :enabled => true,
                 :style => {:fontWeight => 'bold'},
                 :formatter => "function() { return this.y; }".js_code
               })
    end

    @logs = @logs.paginate(:page=>params[:page],:per_page => 50)
  end

  def export
    s_date = params[:s_date].to_time
    e_date = params[:e_date].to_time
    data_cnt = params[:data_cnt]

    start_date = s_date.strftime("%Y-%m-%d %H:%M:%S")
    end_date = e_date.strftime("%Y-%m-%d %H:%M:%S")

    logs = System::AccessLog.extract_csv_date(start_date, end_date,data_cnt)
    csv = CSV.generate do |csv|
      csv << [t("rumi.access_log.th.date"), t("rumi.access_log.th.ip_address"), t("rumi.access_log.th.user_id"), t("rumi.access_log.th.user_name"), t("rumi.access_log.th.feature_name")]
      logs.each do |log|
        row = []
        row << I18n.l(log.created_at, format: :time3)
        row << log.ipaddress
        row << log.user_code
        row << log.user_name
        row << log.feature_name
        csv << row
      end
    end
    csv = NKF.nkf('-Ws -Lw', csv)
    send_data(csv, :type => 'text/csv; charset=Shift_JIS',
              :filename => "access_logs_#{s_date.strftime("%Y%m%d-%H%M%S")}_#{e_date.strftime("%Y%m%d-%H%M%S")}.csv")
  end
end

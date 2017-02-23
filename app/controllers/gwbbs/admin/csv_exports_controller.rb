# -*- encoding: utf-8 -*-
class Gwbbs::Admin::CsvExportsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  layout "admin/template/portal"
  
  def initialize_scaffold
    @title = Gwbbs::Control.find_by_id(params[:id])
    return http_error(404) unless @title
    @piece_head_title = I18n.t("rumi.bbs.name")
    Page.title = @title.title
  end

  def index
    return http_error(403) unless @gw_admin
    params[:nkf] = 'sjis'
  end

  def export_csv
    return http_error(403) unless @gw_admin

    filename = "#{@piece_head_title}-#{@title.title}-#{Time.now.strftime('%Y%m%d-%H%M')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    items = @title.docs.public_docs.order(:id)
                  .select("id, section_code, section_name, category1_id, title")

    #category_hash

    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  []
    csv_header << I18n.t("rumi.bbs.csv_fields.record_id")
    csv_header << I18n.t("rumi.bbs.csv_fields.section_code")
    csv_header << I18n.t("rumi.bbs.csv_fields.section_name")
    csv_header << I18n.t("rumi.bbs.csv_fields.category_code")
    csv_header << I18n.t("rumi.bbs.csv_fields.category_name")
    csv_header << I18n.t("rumi.bbs.csv_fields.title")

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    send_data NKF::nkf(nkf_options,csv_string), :filename => "#{filename}.csv"
  end

  def make_csv(b)
    data = []
    data << b.id.to_s
    data << b.section_code.to_s
    data << b.section_name.to_s
    data << b.category1_id.to_s
    strcat = ''
    #strcat = @categories[b.category1_id].name unless @categories.blank?
    data << strcat
    data << b.title.to_s
    return data
  end

private
  def invalidtoken
    return http_error(404)
  end
end

# -*- encoding: utf-8 -*-
class Gwcircular::Admin::Menus::CsvExportsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwcircular::Model::DbnameAlias
  include Gwcircular::Controller::Authorize
  include Gwcircular::GwcircularHelper
  include Gwcircular::DocsHelper

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  layout "admin/template/portal"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title
    @piece_head_title = t('rumi.circular.name')
    @side = "gwcircular"
    @parent = Gwcircular::Doc.find_by(id: params[:id])
    return http_error(404) unless @parent
    return http_error(404) unless @parent.doc_type == 0
    return redirect_to("#{gwcircular_menus_path}#{s_cond}") if params[:reset]
    get_piece_menus
  end

  def index
    get_role_index

    @is_readable = false unless @parent.target_user_code == Core.user.code unless @gw_admin
    return authentication_error(403) unless @is_readable
    Page.title = t('rumi.circular.name')
    params[:nkf] = 'sjis'
  end

  def export_csv
    filename = "gwcircular#{Time.now.strftime('%Y%m%d%H%M%S')}"
    nkf_options = case params[:item][:nkf]
        when 'utf8'
          '-w'
        else
          '-s'
        end
    items = Gwcircular::Doc.where(title_id: @title.id, doc_type: 1, parent_id: @parent.id)
                          .where("state != 'preparation'")
                          .select("parent_id, title, id, state, section_code, target_user_code, target_user_name, body, editdate, doc_type")

    put1 = []
    items.each do |b|
      put1 << make_csv(b)
    end

    csv_header =  []
    csv_header << I18n.t("rumi.circular.csv_fields.parent_id")
    csv_header << I18n.t("rumi.circular.csv_fields.title")
    csv_header << I18n.t("rumi.circular.csv_fields.status")
    csv_header << I18n.t("rumi.circular.csv_fields.section_name")
    csv_header << I18n.t("rumi.circular.csv_fields.user_name")
    csv_header << I18n.t("rumi.circular.csv_fields.body")
    csv_header << I18n.t("rumi.circular.csv_fields.editdate")

    put2 = [csv_header]
    put1.each do |p|
      put2 << p
    end

    options={:force_quotes => true ,:header=>nil }
    csv_string = Gw::Script::Tool.ary_to_csv(put2, options)
    send_data(NKF::nkf(nkf_options,csv_string), :type => 'text/csv', :filename => "#{filename}.csv")
  end

  def make_csv(b)
    section_name = get_current_group_name(b.section_code)
    data = []
    data << b.parent_id.to_s
    data << b.title.to_s
    data << b.status_name_csv.to_s
    data << section_name.to_s
    data << b.target_user_name.to_s
    data << b.body.to_s
    data << (b.editdate.present? ? I18n.l(b.editdate.to_time) : b.editdate.to_s)
    return data
  end


  private
  def invalidtoken
    return http_error(404)
  end
end

# -*- encoding: utf-8 -*-
class Gwcircular::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Gwcircular::Model::Systemname

  validates_presence_of :state, :recognize, :title, :sort_no, :commission_limit
  validates_presence_of :upload_graphic_file_size_capacity, :upload_graphic_file_size_max, :upload_document_file_size_max
  after_validation :validate_params
  before_save :set_icon_and_wallpaper_path
  after_save :save_admingrps, :save_editors, :save_readers, :save_readers_add, :save_sueditors, :save_sureaders

  attr_accessor :_makers
  attr_accessor :_design_publish

  def save_admingrps

    unless self.admingrps_json.blank?
      Gwcircular::Adm.where("title_id=#{self.id}").destroy_all
      groups = JsonParser.new.parse(self.admingrps_json)
      @dsp_admin_name = ''
      groups.each do |group|
        item_grp = Gwcircular::Adm.new()
        item_grp.title_id = self.id
        item_grp.user_id = 0
        item_grp.user_code = nil
        item_grp.group_id = group[1]
        item_grp.group_code = group_code(group[1])
        item_grp.group_name = group[2]
        item_grp.save!
        @dsp_admin_name = group[2] if @dsp_admin_name.blank?
      end
    end
    save_adms
    unless self.dsp_admin_name == @dsp_admin_name
      strsql = "UPDATE gwcircular_controls SET dsp_admin_name = '#{@dsp_admin_name}' WHERE id ='#{self.id}'"
      self.class.connection.execute(strsql)
    end
  end

  def save_adms
    unless self.adms_json.blank?
      users = JsonParser.new.parse(self.adms_json)
      users.each do |user|
        item_adm = Gwcircular::Adm.new()
        item_adm.title_id = self.id
        item_adm.user_id = user[1].to_i
        item_user = System::User.find(item_adm.user_id)
        if item_user
          tg = item_user.groups[0]
          item_adm.user_id = item_user[:id]
          item_adm.user_code = item_user[:code]
          item_adm.group_id = tg[:group_id]
          item_adm.group_code = tg[:code]
          @dsp_admin_name = tg[:name] unless tg[:name].blank? if @dsp_admin_name.blank?
        end
        item_adm.user_name = user[2]
        item_adm.save!
      end
    end
  end

  def save_editors
    unless self.editors_json.blank?
      Gwcircular::Role.where("title_id=#{self.id} and role_code = 'w'").destroy_all
      groups = JsonParser.new.parse(self.editors_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Gwcircular::Role.new()
          item_grp.title_id = self.id
          item_grp.role_code = 'w'
          item_grp.group_code = group_code(group[1])
          item_grp.group_code = '0' if group[1].to_s == '0'
          item_grp.group_id = group[1]
          item_grp.group_name = group[2]
          item_grp.save! unless item_grp.group_code.blank?
        end
      end
    end
  end

  def save_readers
    unless self.readers_json.blank?
      Gwcircular::Role.where("title_id=#{self.id} and role_code = 'r'").destroy_all
      groups = JsonParser.new.parse(self.readers_json)
      groups.each do |group|
        unless group[1].blank?
          item_grp = Gwcircular::Role.new()
          item_grp.title_id = self.id
          item_grp.role_code = 'r'
          item_grp.group_code = group_code(group[1])
          item_grp.group_code = '0' if group[1].to_s == '0'
          item_grp.group_id = group[1]
          item_grp.group_name = group[2]
          item_grp.save!  unless item_grp.group_code.blank?
        end
      end
    end
  end

  def save_readers_add
    unless self.editors_json.blank?

      item = Gwcircular::Role.where("title_id=#{self.id} and role_code = 'r' and group_code = '0'")
      if item.length == 0

        groups = JsonParser.new.parse(self.editors_json)

        groups.each do |group|
          unless group[1].blank?
            item_grp = Gwcircular::Role.where("title_id=#{self.id} and role_code = 'r' and group_id = #{group[1]}")
            if item_grp.length == 0
              item_grp = Gwcircular::Role.new()
              item_grp.title_id = self.id
              item_grp.role_code = 'r'
              item_grp.group_code = group_code(group[1])
              item_grp.group_code = '0' if group[1].to_s == '0'
              item_grp.group_id = group[1]
              item_grp.group_name = group[2]
              item_grp.save! unless item_grp.group_code.blank?
            end
          end
        end
      end
    end
  end

  def save_sueditors
    unless self.sueditors_json.blank?
      suedts = JsonParser.new.parse(self.sueditors_json)
      suedts.each do |suedt|
        unless suedt[1].blank?

          item_sue = Gwcircular::Role.new()
          item_sue.title_id = self.id
          item_sue.role_code = 'w'
          item_sue.user_id = suedt[1].to_i
          item_user = System::User.find(item_sue.user_id)
          if item_user
            item_sue.user_id = item_user[:id]
            item_sue.user_code = item_user[:code]
          end
          item_sue.user_name = suedt[2]
          item_sue.save!

          item_sue = Gwcircular::Role.new()
          item_sue.title_id = self.id
          item_sue.role_code = 'r'
          item_sue.user_id = suedt[1].to_i
          item_user = System::User.find(item_sue.user_id)
          if item_user
            item_sue.user_id = item_user[:id]
            item_sue.user_code = item_user[:code]
          end
          item_sue.user_name = suedt[2]
          item_sue.save!
        end
      end
    end
  end

  def save_sureaders
    unless self.sueditors_json.blank?
      surds = JsonParser.new.parse(self.sureaders_json)
      surds.each do |surd|
        unless surd[1].blank?
          item_sur = Gwcircular::Role.new()
          item_sur.title_id = self.id
          item_sur.role_code = 'r'
          item_sur.user_id = surd[1].to_i
          item_user = System::User.find(item_sur.user_id)
          if item_user
            item_sur.user_id = item_user[:id]
            item_sur.user_code = item_user[:code]
          end
          item_sur.user_name = surd[2]
          item_sur.save!
        end
      end
    end
  end

  def group_code(id)
    item = System::Group.find_by(id: id)
    ret = ''
    ret = item.code if item
    return ret
  end

  def validate_params
    errors.add :default_published, I18n.t('rumi.gwcircular.message.validate_num') if self.default_published.blank?
    errors.add :default_published, I18n.t('rumi.gwcircular.message.validate_num') if self.default_published == 0
    errors.add :upload_graphic_file_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_graphic_file_size_capacity.blank?
    errors.add :upload_graphic_file_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_graphic_file_size_capacity == 0
    errors.add :upload_document_file_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_document_file_size_capacity.blank?
    errors.add :upload_document_file_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_document_file_size_capacity == 0
    errors.add :upload_graphic_file_size_max, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_graphic_file_size_max.blank?
    errors.add :upload_graphic_file_size_max, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_graphic_file_size_max == 0
    errors.add :upload_document_file_size_max, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_document_file_size_max.blank?
    errors.add :upload_document_file_size_max, I18n.t('rumi.gwcircular.message.validate_num') if self.upload_document_file_size_max == 0
    errors.add :doc_body_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.doc_body_size_capacity.blank?
    errors.add :doc_body_size_capacity, I18n.t('rumi.gwcircular.message.validate_num') if self.doc_body_size_capacity == 0
  end

  def item_home_path
    return "/gwcircular/"
  end

  def menus_path
    return self.item_home_path
  end

  def custom_groups_path
    return self.item_home_path + "custom_groups/"
  end

  def docs_path
    return self.item_home_path + "docs/"
  end

  def adm_show_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def delete_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def update_nt_path
    return self.item_home_path + "basics/#{self.id}"
  end

  def design_publish_path
    return self.item_home_path + "basics/#{self.id}/design_publish"
  end

  def set_icon_and_wallpaper_path
    return unless self._makers
  end

  def original_css_file
    return Rails.root.join("public/_common/themes/gw/css/option.css")
  end

  def board_css_file_path
    return Rails.root.join("public/_attaches/css/#{self.system_name}")
  end

  def board_css_preview_path
    return Rails.root.join("public/_attaches/css/preview/#{self.system_name}")
  end

  def default_limit_circular
    return [
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_10'), 10],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_20'), 20],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_30'), 30],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_50'), 50],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_100'),100],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_150'),150],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_200'),200],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_250'),250]
    ]
  end

  def delete_date_setting_states
    {'none' => I18n.t('rumi.gwcircular.select_item.delete_date_setting.none'), 'use' => I18n.t('rumi.gwcircular.select_item.delete_date_setting.use')}
  end

  class << self

    # === 新着情報取得メソッド
    #  新着情報に表示する未読の回覧情報を取得する
    # ==== 引数
    #  * user_id: ユーザーID
    #  * sort_key: 並び替えするKey（日付／概要）
    #  * order: 並び順（昇順／降順）
    # ==== 戻り値
    #  回覧情報(Hashオブジェクト)
    def remind(user_id, sort_key = "updated_at", order = "desc")
      gwcircular_records = Gw::Reminder.extract_gwcircular(user_id, sort_key, order)
      total_count = gwcircular_records.count
      reply_cnt = 0
      relation = Array.new
      reply_count = Array.new
      gwcircular_record_urls = Array.new
      gwcircular_records.each do |record|
        break if relation.count >= Enisys.config.application['gw.reminder_view_size'].to_i
        if record.action == 'reply'
          record_exist = gwcircular_record_urls.find{|x| x == record.url}
          next if record_exist.present?

          record_cnt = gwcircular_records.where(url: record.url, action: 'reply').count
          relation << record
          reply_count << record_cnt
          total_count = total_count - record_cnt + 1
          gwcircular_record_urls << record.url
        else
          relation << record
          reply_count << 0
          reply_cnt = 0
        end
      end

      return nil if total_count.zero?
      return {
        total_count: total_count,
        factors: relation,
        reply_count: reply_count
      }
    end

    # === 通知件数取得メソッド
    #  ログインユーザーが閲覧権限を持つ未読の回覧件数を取得する
    # ==== 引数
    #  * user_id: ユーザーID
    # ==== 戻り値
    #  通知件数(整数)
    def notification(user_id)
      record_cnt = 0
      gwcircular_record_urls = Array.new
      gwcircular_records = Gw::Reminder.extract_gwcircular(user_id, nil, nil)
      gwcircular_records.each do |record|
        if record.action == 'reply'
          record_exist = gwcircular_record_urls.find{|x| x == record.url}
          next if record_exist.present?
          gwcircular_record_urls << record.url
        end
        record_cnt += 1
      end
      return record_cnt
    end
  end
end

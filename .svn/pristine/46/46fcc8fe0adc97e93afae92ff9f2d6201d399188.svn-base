# -*- encoding: utf-8 -*-
class Gwcircular::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Recognition
  include Gwcircular::Model::Systemname

  has_many :files, :foreign_key => :parent_id, :class_name => 'Gwcircular::File', :dependent => :destroy
  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Gwcircular::Control'
  belongs_to :parent_doc, :foreign_key => :parent_id, :class_name => 'Gwcircular::Doc'
  has_many :reminders, -> (doc){ where(category: "circular", title_id: doc.title_id ) }, foreign_key: :item_id, dependent: :destroy, class_name: "Gw::Reminder"


  # === 転送用の元記事情報を取得するスコープ
  #
  # ==== 引数
  #  * target_id: 転送用の元記事ID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :get_forward, lambda { |target_id|
    where(id: target_id)
  }

  validates_presence_of :state, :able_date, :expiry_date
  after_validation :validate_title
  after_save :check_digit, :create_delivery, :update_commission_count, :update_circular_reminder
  after_destroy :commission_delete
  attr_accessor :_inner_process
  attr_accessor :_commission_count
  attr_accessor :_commission_state
  attr_accessor :_commission_limit
  before_update :set_importance

  def validate_title
    if self.title.blank?
      errors.add :title, I18n.t("rumi.gwcircular.message.validate_title")
      self.state = 'draft' unless self._commission_state == 'public'
    else
      str = self.title.to_s.gsub(/　/, '').strip
      if str.blank?
        errors.add :title, I18n.t("rumi.gwcircular.message.validate_title_space")
        self.state = 'draft' unless self._commission_state == 'public'
      end
      unless str.blank?

        s_chk = self.title.gsub(/\r\n|\r|\n/, '')
        self.title = s_chk
        if 140 < s_chk.split(//).size
          errors.add :title, I18n.t("rumi.gwcircular.message.validate_title_limit")
          self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        end
      end
    end if self.doc_type == 0 unless self.state == 'preparation'

    unless self.body.blank?
      errors.add :body, I18n.t("rumi.gwcircular.message.validate_body_limit") if 140 < self.body.split(//).size
    end if self.doc_type == 1

    if self.able_date > self.expiry_date
      errors.add :expiry_date, I18n.t("rumi.gwcircular.message.validate_expiry_date")
      self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
    end unless self.able_date.blank? unless self.expiry_date.blank?

    if self.doc_type == 0
      cnt = 0
      a_grp = []
      a_usr = []
      unless self.reader_groups_json.blank?
        objects = JsonParser.new.parse(self.reader_groups_json)
        for object in objects
          a_grp << object[1]
        end
      end
      unless self.readers_json.blank?
        objects = JsonParser.new.parse(self.readers_json)
        for obj in objects
          a_usr << obj[1]
        end
      end
      chk_array = a_grp | a_usr
      cnt = chk_array.count

      if self._commission_limit < cnt
        self.state = 'draft' unless self._commission_state == 'public'  #入力エラーが発生した時に下書きボタンが消えてしまう現象の対応：送信前が公開以外なら下書きボタンを表示させる
        errors.add :state, I18n.t('rumi.gwcircular.message.validate_commission_limit', cnt: cnt, commission_limit: self._commission_limit)
      end
    end unless self._commission_limit.blank? unless self.state == 'preparation'
  end

  def update_circular_reminder
    return nil unless self._commission_count
    return nil unless self.doc_type == 1

  end

  def create_delivery
    return nil unless self._commission_count

    before_create_delivery
    save_reader_groups_json
    save_readers_json
    after_create_delivery
  end

  def before_create_delivery
    return nil if self.doc_type == 1

    condition = "title_id=#{self.title_id} AND parent_id=#{self.id} AND doc_type=1"
    Gwcircular::Doc.where(condition).update_all("category4_id = 9")
  end

  def save_reader_groups_json
    return nil if self._inner_process
    return nil if self.doc_type == 1
    unless self.reader_groups_json.blank?
      objects = JsonParser.new.parse(self.reader_groups_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_delivery_data(user)
        end
      end
    end if self.doc_type == 0
  end

  def save_readers_json
    return nil if self._inner_process
    return nil if self.doc_type == 1
    unless self.readers_json.blank?
      objects = JsonParser.new.parse(self.readers_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_delivery_data(user)
        end
      end
    end if self.doc_type == 0
  end

  def after_create_delivery
    return nil if self.doc_type == 1

    objcts = Gwcircular::Doc.where(title_id: self.title_id, parent_id: self.id, doc_type: 1, category4_id: 9)
    for object in objcts
      object.state = 'preparation'
      object.save
    end

    docs = Gwcircular::Doc.where(state: 'preparation', title_id: self.title_id, parent_id: self.id, doc_type: 1, category4_id: 0)
    for doc in docs
      doc.state = 'draft'
      doc.save
    end
  end

  def update_commission_count
    return nil if self._inner_process
    return nil if self.doc_type == 1 unless self._commission_count
    self.commission_count_update(self.parent_id) if self.doc_type == 1 if self._commission_count
    self.commission_count_update(self.id) if self.doc_type == 0
  end

  def get_custom_group_users(gid)
    iet = ''
    retem = Gwcircular::CustomGroup.find_by(id: gid)
    rt = item.readers_json unless item.blank?
    return ret
  end

  def get_group_user_items(gid)
    item = System::User
    return item.select('system_users.id, system_users.code, system_users.name').where("system_users.state = 'enabled' AND system_users_groups.group_id = #{gid}").joins('inner join system_users_groups on system_users.id = system_users_groups.user_id').order('system_users.code')
  end

  def is_vender_user
    ret = false
    ret = true if Site.user.code.length <= 3
    ret = true if Site.user.code == 'gwbbs'
    return ret
  end

  def get_user_items(uid)
    item = System::User
    return item.select('system_users.id, system_users.code, system_users.name').where("system_users.state = 'enabled'").where("system_users_groups.user_id = #{uid}").joins('inner join system_users_groups on system_users.id = system_users_groups.user_id').order('system_users.code')
  end

  def create_delivery_data(user)
    return nil if user.blank?
    group_code = ''
    group_name = ''
    group_code = user.enable_user_groups.first.group.code
    group_name = user.enable_user_groups.first.group.name

    item = Gwcircular::Doc
    doc = item.where(title_id: self.title_id, parent_id: self.id, doc_type: 1, target_user_code: user.code).first
    if doc.blank?
      doc_item = Gwcircular::Doc.create({
        :state => 'draft',
        :title_id => self.title_id,
        :parent_id => self.id,
        :doc_type => 1,
        :target_user_id => user.id,
        :target_user_code => user.code,
        :target_user_name => user.name,
        :confirmation => self.confirmation,
        :section_code => group_code,
        :section_name => group_name,
        :latest_updated_at => Time.now,
        :title => self.title,
        :spec_config => self.spec_config,
        :importance => self.importance,
        :able_date => self.able_date,
        :expiry_date => self.expiry_date ,
        :createdate => self.createdate ,
        :creater_id => self.creater_id ,
        :creater => self.creater ,
        :createrdivision => self.createrdivision ,
        :createrdivision_id => self.createrdivision_id ,
        :category4_id => 0
      })
      unless doc_item.blank?
        doc_item.doc_type = 1
        doc_item.target_user_id = user.id
        doc_item.target_user_code = user.code
        doc_item.target_user_name = user.name
        doc_item.section_code = group_code
        doc_item.section_name = group_name
        doc_item.category4_id = 0
        doc_item.save
      end
    else

      doc.confirmation = self.confirmation
      doc.title = self.title
      doc.spec_config = self.spec_config
      doc.importance = self.importance
      doc.able_date = self.able_date
      doc.expiry_date = self.expiry_date
      doc.createdate = self.createdate
      doc.creater_id = self.creater_id
      doc.creater = self.creater
      doc.createrdivision = self.createrdivision
      doc.createrdivision_id = self.createrdivision_id
      doc.category4_id = 0
      # doc.stateはpublish_delivery_dataで'unread'に変更する。
      before_state = doc.state
      doc.state = 'draft'
      doc.save
    end
  end

  def publish_delivery_data(parent_id)
    item = Gwcircular::Doc
    docs = item.where(title_id: self.title_id, parent_id: parent_id, state: 'draft', doc_type: 1)
    for doc in docs
      unless doc.category3_id == 1
        doc.category3_id = 1
      end
      doc.state = 'unread'
      doc.save
    end

    self.commission_count_update(parent_id)
  end

  def commission_count_update(parent_id)
    condition = "state !='preparation' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    commission_count = Gwcircular::Doc.where(condition).count

    condition = "state='draft' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    draft_count = Gwcircular::Doc.where(condition).count

    condition = "state='unread' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    unread_count = Gwcircular::Doc.where(condition).count

    condition = "state='already' AND title_id=#{self.title_id} AND parent_id=#{parent_id} AND doc_type=1"
    already_count = Gwcircular::Doc.where(condition).count

    item = Gwcircular::Doc.find_by(id: parent_id)
    return nil if item.blank?
    item.commission_count = commission_count
    item.draft_count = draft_count
    item.unread_count = unread_count
    item.already_count = already_count
    item._inner_process = true
    item.save
  end

  def commission_info
    ret = ''
    ret = "(#{self.already_count}/#{self.commission_count})" unless self.state == 'draft'
    undelivered = I18n.t('rumi.gwcircular.select_item.delivery_status.undelivered')
    ret += "(#{undelivered}#{self.draft_count})" unless self.draft_count == 0
    return ret
  end

  def commission_delete
    return unless self.doc_type == 0

    Gwcircular::Doc.where("parent_id=#{self.id}").destroy_all
  end

  def status_name
    str = ''
    if self.doc_type == 0
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.draft') if self.state == 'draft'
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.public') if self.state == 'public'
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.public_end') if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    if self.doc_type == 1
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.preparation') if self.state == 'preparation'
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.still') if self.state == 'draft'
      str = '<div><span class="required">' + I18n.t('rumi.gwcircular.select_item.delivery_status.unread') + '</span></div>' if self.state == 'unread'
      str = '<div><span class="notice">' + I18n.t('rumi.gwcircular.select_item.delivery_status.already') + '</span></div>' if self.state == 'already'
      str = I18n.t('rumi.gwcircular.select_item.delivery_status.public_limit') if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    return str
  end

  def status_name_csv
    str = ''
    if self.doc_type == 0
      str = I18n.t('rumi.state.draft') if self.state == 'draft'
      str = I18n.t('rumi.state.public') if self.state == 'public'
      str = I18n.t('rumi.state.public_end') if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    if self.doc_type == 1
      str = I18n.t('rumi.state.preparation') if self.state == 'preparation'
      str = I18n.t('rumi.state.still') if self.state == 'draft'
      str = I18n.t('rumi.state.unread') if self.state == 'unread'
      str = I18n.t('rumi.state.already') if self.state == 'already'
      str = I18n.t('rumi.state.public_limit') if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    end
    return str
  end

  def spec_config_name
    return [
      [I18n.t("rumi.circular.spec_config_state.only"), 0] ,
      [I18n.t("rumi.circular.spec_config_state.other_name"), 3] ,
      [I18n.t("rumi.circular.spec_config_state.other_all"), 5]
    ]
  end

  def spec_config_name_status
    ret = ''
    ret = I18n.t("rumi.circular.spec_config_state.only") if self.spec_config == 0
    ret = I18n.t("rumi.circular.spec_config_state.other_name") if self.spec_config == 3
    ret = I18n.t("rumi.circular.spec_config_state.other_all") if self.spec_config == 5
    return ret
  end

  def importance_states_select
    return [
      [I18n.t('rumi.gwcircular.select_item.status.importance'), 0] ,
      [I18n.t('rumi.gwcircular.select_item.status.normal'), 1]
    ]
  end

  def is_readable_edit_show?
    if self.spec_config == 5
      return true
    else
      false
    end
  end

  def already_body
    ret = ''
    # 既読状態、または未読状態でコメントデータがある場合（既読後に編集があった場合）
    # コメントを表示する
    if self.state == 'already' || (self.state == 'unread' && self.body.present?)
      ret = self.body
    end

    return ret
  end

  def unread_comment(circular_menus_id)
    # 未読のコメントである場合、NEW画像表示
    remind = Gw::Reminder.where(category: "circular", action: "reply")
                         .where(sub_category: self.id, title_id: self.title_id)
                         .where("seen_at is null")
    return remind.present?
  end

  def display_opendocdate
    ret = ''
    ret = I18n.l self.published_at.to_datetime unless self.published_at.blank?
    return ret
  end

  def display_editdate
    ret = ''
    ret = I18n.l self.editdate.to_datetime unless self.editdate.blank?
    return ret
  end

  def public_path
    if name =~ /^[0-9]{8}$/
      _name = name
    else
      _name = File.join(name[0..0], name[0..1], name[0..2], name)
    end
    Site.public_path + content.public_uri + _name + '/index.html'
  end

  def public_uri
    content.public_uri + name + '/'
  end

  def check_digit
    return true if name.to_s != ''
    return true if @check_digit == true

    @check_digit = true

    self.name = Util::CheckDigit.check(format('%07d', id))
    save
  end

  def self.search(params)
    doc_arel_table = self.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
       or_cond  = []
        *columns = :title, :body
        v.to_s.split(/[ 　]+/).each_with_index do |w, i|
          break if i >= 10
          columns.each do |col|
            qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
            or_cond << doc_arel_table[col].matches("%#{qw}%")
          end
        end
        or_cond1 = or_cond.shift
        or_cond.each do |c|
          or_cond1 = or_cond1.or c
        end
        and_cond << or_cond1
      #期限日を検索条件に追加
      when 'expirydate_start'
        and_cond << doc_arel_table[:expiry_date].gteq(v+" 00:00:00")
      when 'expirydate_end'
        and_cond << doc_arel_table[:expiry_date].lteq(v+" 23:59:59")
      #作成日を検索条件に追加
      when 'createdate_start'
        and_cond << doc_arel_table[:created_at].gteq(v+" 00:00:00")
      when 'createdate_end'
        and_cond << doc_arel_table[:created_at].lteq(v+" 23:59:59")
      end
    end if params.size != 0
    if and_cond.present?
      and_cond1 = and_cond.shift
      and_cond.each do |c|
        and_cond1 = and_cond1.and c
      end
      and_cond = and_cond1
    end
    return self.where(and_cond)
  end

  def self.search_kwd(params)
    doc_arel_table = self.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        or_cond  = []
        *columns = :title, :body
        v.to_s.split(/[ 　]+/).each_with_index do |w, i|
          break if i >= 10
          columns.each do |col|
            qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
            or_cond << doc_arel_table[col].matches("%#{qw}%")
          end
        end
        or_cond1 = or_cond.shift
        or_cond.each do |c|
          or_cond1 = or_cond1.or c
        end
        and_cond << or_cond1
      end
    end if params.size != 0
    if and_cond.present?
      and_cond1 = and_cond.shift
      and_cond.each do |c|
        and_cond1 = and_cond1.and c
      end
      and_cond = and_cond1
    end
    return self.where(and_cond)
  end

  def self.search_creator(params)
    doc_arel_table = self.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      #作成者を検索条件に追加
      when 'creator'
        or_cond  = []
        quote_string = connection.quote_string(v).gsub(/([_%])/, '\\\\\1')

        # == 作成者名での部分一致検索条件 ==
        or_cond << doc_arel_table[:creater].matches("%#{quote_string}%")
        # == 所属名での部分一致検索条件 ==
        # 所属名で部分一致するSystem::Groupを取得
        groups = System::Group.where("name LIKE '%#{quote_string}%'")

        # 所属コード配列を取得
        # ※Gwbbs::Doc.createrdivision_idには所属コードが登録されているので
        # 　検索条件には所属コードを使用する
        group_codes = groups.map(&:code)
        or_cond << doc_arel_table[:createrdivision_id].in(group_codes)

        or_cond1 = or_cond.shift
        or_cond.each do |c|
          or_cond1 = or_cond1.or c
        end
        and_cond << or_cond1
      end
    end if params.size != 0
    if and_cond.present?
      and_cond1 = and_cond.shift
      and_cond.each do |c|
        and_cond1 = and_cond1.and c
      end
      and_cond = and_cond1
    end
    return self.where(and_cond)
  end

  def self.search_date(params)
    doc_arel_table = self.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      #期限日を検索条件に追加
      when 'expirydate_start'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:expiry_date].gteq(value+" 00:00:00")
      when 'expirydate_end'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:expiry_date].lteq(value+" 23:59:59")
      #作成日を検索条件に追加
      when 'createdate_start'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:created_at].gteq(value+" 00:00:00")
      when 'createdate_end'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:created_at].lteq(value+" 23:59:59")
      end
    end if params.size != 0
    if and_cond.present?
      and_cond1 = and_cond.shift
      and_cond.each do |c|
        and_cond1 = and_cond1.and c
      end
      and_cond = and_cond1
    end
    return self.where(and_cond)
  rescue
    return self.where([])
  end

  def importance_name
    return self.importance_states[self.importance.to_s]
  end

  def item_home_path
    return "/gwcircular/"
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}"
  end

  def show_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}"
    else
      return "#{self.item_home_path}docs/#{self.id}"
    end
  end

  def edit_path
    return "#{Site.current_node.public_uri}#{self.id}/edit"
  end

  def doc_edit_path
    return "#{self.item_home_path}docs/#{self.id}/edit"
  end

  def doc_state_already_update
    return "#{self.item_home_path}docs/#{self.id}/already_update"
  end

  def clone_path
    return "#{Site.current_node.public_uri}#{self.id}/clone"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end

  def csv_export_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/csv_exports"
    else
      return '#'
    end
  end

  def csv_export_file_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/csv_exports/export_csv"
    else
      return '#'
    end
  end

  def file_export_path
    if self.doc_type == 0
      return "#{self.item_home_path}#{self.id}/file_exports"
    else
      return '#'
    end
  end

  def is_date(date_state)
    begin
      date_state.to_time
    rescue
      return false
    end
    return true
  end

  def self.json_array_select_trim(datas)
    return [] if datas.blank?
    datas.each do |data|
      data.delete_at(0)
      data.reverse!
    end
    return datas
  end

  def str_attache_span
    ret = ''
    files = Gwcircular::File.where(title_id: 1, parent_id: self.id)
    return ret if files.blank?

    total_count = files.count
    ret = "<span>#{total_count.to_s}</span>" if total_count.to_s != '0'
    return ret
  end

  def set_importance
    self.importance = 1  unless self.importance.present?
  end

  # === 新着情報作成メソッド
  #  指定ユーザーに対して新着情報を作成するメソッドである。
  # ==== 引数
  #  * user_id: ユーザーID
  #  * datetime: 日付
  #  * action: 操作名（'create': 新規作成 / 'update': 更新 / 'reply': コメント）
  # ==== 戻り値
  #  Gw::Reminder
  def build_remind(user_id, datetime, action)
    # ユーザーの閲覧画面用回覧を取得
    if action != 'reply'
      controller_name = 'docs'
      user_doc = Gwcircular::Doc.where(title_id: self.title_id,
                                       parent_id: self.id,
                                       target_user_id: user_id).first
      gwcircular_id = user_doc.id
      Gw::Reminder.create!(category: 'circular',
                           user_id: user_id,
                           title_id: self.title_id,
                           item_id: self.id,
                           title: self.title,
                           datetime: datetime,
                           action: "#{action}",
                           url: "/gwcircular/#{controller_name}/#{gwcircular_id}")
    else
      controller_name = 'menus'
      gwcircular_id = self.parent_id.present? ? self.parent_id : self.id
      child_doc = Gwcircular::Doc.where(parent_id: gwcircular_id, target_user_id: Site.user.id).first

      unseen_comment = Gw::Reminder.where(category: 'circular', sub_category: child_doc.id, action: "reply", item_id: self.id)
                                   .where("seen_at is null")
      if unseen_comment.blank?
        Gw::Reminder.create!(category: 'circular',
                             sub_category: child_doc.id,
                             user_id: user_id,
                             title_id: self.title_id,
                             item_id: self.id,
                             title: self.title,
                             datetime: datetime,
                             action: "#{action}",
                             url: "/gwcircular/#{controller_name}/#{gwcircular_id}")
      end
    end
  end

  # === 新着情報（作成時）を作成するメソッド
  #  配信者のユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def build_created_remind
    # 配信者のユーザーID取得
    item = Gwcircular::Doc
    docs = item.where(title_id: self.title_id, parent_id: self.id, state: 'draft', doc_type: 1).all.to_a
    user_ids = docs.map(&:target_user_id)

    # 配信者のユーザーに通知する
    user_ids.each do |user_id|
      target_user = System::User.find(user_id)
      # 無効ユーザーには通知しない
      build_remind(user_id, self.updated_at, 'create') unless target_user.disabled?
    end
  end

  # === 新着情報(更新時)を作成するメソッド
  #  配信者のユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def build_updated_remind
    # 配信者のユーザーID取得
    item = Gwcircular::Doc
    docs = item.where(title_id: self.title_id, parent_id: self.id, state: 'draft', doc_type: 1).all.to_a
    user_ids = docs.map(&:target_user_id)

    # 配信者のユーザーに通知する
    user_ids.each do |user_id|
      target_user = System::User.find(user_id)
      # 無効ユーザーには通知しない
      build_remind(user_id, self.updated_at, 'update') unless target_user.disabled?
    end
  end

  # === 新着情報(コメント時)を作成するメソッド
  #  配信者のユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def build_reply_remind
    docs = Gwcircular::Doc.where(id: self.id).first
    # 配信者のユーザーに通知する
    target_user = System::User.where(code: docs.creater_id).first
    # 無効ユーザーには通知しない
    build_remind(target_user.id, self.updated_at, 'reply') unless target_user.disabled?
  end

  # === 新着情報を既読にするメソッド
  #  ユーザーに対して実行する
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  なし
  def seen_remind(user_id)
    reminders.extract_user_id(user_id).each do |reminder|
      # 既読にする
      reminder.seen if reminder.action != 'reply'
    end
  end

  # === コメントの新着情報を既読にするメソッド
  #  ユーザーに対して実行する
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  なし
  def seen_reply_remind(user_id)
    gwcircular_id = self.parent_id.present? ? self.parent_id : self.id
    reply_reminders = Gw::Reminder.where(category: "circular", title_id: self.title_id)
                                  .where(user_id: user_id, action: 'reply')
                                  .where(item_id: gwcircular_id)

    reply_reminders.each do |reminder|
      # 既読にする
      reminder.seen
    end
  end

  # === 未読か評価するメソッド
  #  ユーザーに対して実行する
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  boolean true: 未読 false: 既読
  def unseen?(user_id)
    reminders.extract_user_id(user_id).where("action != 'reply'").exists?
  end

  # === 新着情報削除メソッド
  #  該当回覧に対する新着情報を全て削除するメソッドである。
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def desroy_reminder_all
    reminders.each do |reminder|
      # 新着情報を削除する
      reminder.destroy
    end
  end

  # === 記事の年月情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :select_monthly_info, lambda {
    select("DATE_FORMAT(created_at,'%Y年%m月') AS month, DATE_FORMAT(created_at,'%Y') AS yy, DATE_FORMAT(created_at,'%m') AS mm, count(id) as cnt").group("DATE_FORMAT(created_at,'%Y年%m月')").order("DATE_FORMAT(created_at,'%Y年%m月') DESC")
  }

  # === 記事の所属情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :select_createrdivision_info, lambda {
    select("*, count(id) as cnt").group("createrdivision_id").order("createrdivision_id ASC")
  }

  # === 未読情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * title_id: タイトルID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :unread_info, lambda { |title_id|
    where(["title_id = ? and doc_type = ? and target_user_code = ? and state = ?", title_id, 1, Core.user.code, 'unread']).where("able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
  }

  # === 既読情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * title_id: タイトルID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :already_info, lambda { |title_id|
    where(["title_id = ? and doc_type = ? and target_user_code = ? and state = ?", title_id, 1, Core.user.code, 'already']).where("able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
  }

  # === 作成した回覧情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * title_id: タイトルID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :owner_info, lambda { |title_id|
    where(["title_id = ? and doc_type = ? and target_user_code = ? and state != ?", title_id, 0, Core.user.code, 'preparation']).where("able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
  }

  # === 管理者情報を抽出するためのスコープ
  #
  # ==== 引数
  #  * title_id: タイトルID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :admin_info, lambda { |title_id|
    where(["title_id = ? and doc_type = ? and state != ?", title_id, 0, 'preparation']).where("able_date <= '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
  }
end

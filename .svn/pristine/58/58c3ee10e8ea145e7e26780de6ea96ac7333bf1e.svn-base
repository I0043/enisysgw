# -*- encoding: utf-8 -*-
class Gwbbs::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::Recognition
  include Gwbbs::Model::Systemname

  belongs_to :control,   :foreign_key => :title_id,     :class_name => 'Gwbbs::Control'
  has_many   :comment,   :foreign_key => :parent_id,    :class_name => 'Gwbbs::Comment'
  has_many   :files,   :foreign_key => :parent_id,    :class_name => 'Gwbbs::File'
  #has_many :reminders, foreign_key: :item_id, dependent: :destroy, class_name: "Gw::Reminder",
  #  conditions: Proc.new { { category: "bbs", title_id: self.title_id } }
  has_many :reminders, -> (doc){ where(category: "bbs", title_id: doc.title_id ) }, foreign_key: :item_id, dependent: :destroy, class_name: "Gw::Reminder"

  validates_presence_of :state, :able_date
  after_validation :validate_title
  before_save :expiry_date_update
  after_save :check_digit, :title_update_save
  after_destroy :doc_body_size_currently_update

  attr_accessor :_notification
  attr_accessor :_bbs_title_name
  attr_accessor :_note_section
  attr_accessor :_no_validation

#    validates :name_editor_section_id, presence: true, if: Proc.new{ |record| (record.name_type == 1 || record.name_type == 2) }
  scope :draft_docs, -> { where(state: 'draft') }
  scope :recognizable_docs, -> { where(state: 'recognize') }
  scope :recognized_docs, -> { where(state: 'recognized') }
  scope :public_docs, -> { where(state: 'public') }

  def validate_title
    return if self._no_validation

    unless self.state == 'preparation'
      item = Gwbbs::Control.find(self.title_id)
      body_size_capacity = 0
      body_size_currently = 0
      body_size_capacity = item.doc_body_size_capacity.megabytes unless item.doc_body_size_capacity.blank?
      body_size_currently = item.doc_body_size_currently unless item.doc_body_size_currently.blank?
      body_size_currently = body_size_currently + self.body.size
      body_size = body_size_currently - body_size_capacity
      errors.add :title, I18n.t('rumi.gwbbs.message.invalid_body_limit', body_size: body_size) if body_size_capacity < body_size_currently unless body_size_capacity == 0
    end unless self.body.blank?

    if self.title.blank?
      errors.add :title, I18n.t('rumi.gwbbs.message.validate_title')
    else
      str = self.title.to_s.gsub(/　/, '').strip
      errors.add :title, I18n.t('rumi.gwbbs.message.validate_title_space') if str.blank?
      unless str.blank?

        s_chk = self.title.gsub(/\r\n|\r|\n/, '')
        self.title = s_chk
        errors.add :title, I18n.t('rumi.gwbbs.message.validate_title_limit') if 140 < s_chk.split(//).size
      end
    end if self.form_name == 'form001' unless self.state == 'preparation'

    if self.category1_id.blank?
      errors.add :category1_id, I18n.t('rumi.gwbbs.message.validate_category1_id')
    end if self.category_use == 1 unless self.state == 'preparation'

    if self.section_code.blank?
      errors.add :section_code, I18n.t('rumi.gwbbs.message.validate_section_code')
    end unless self.state == 'preparation'

    if self.able_date > self.expiry_date
      errors.add :able_date, I18n.t('rumi.gwbbs.message.validate_expiry_date')
      errors.add :expiry_date, I18n.t('rumi.gwbbs.message.validate_expiry_date')
    end unless self.able_date.blank? unless self.expiry_date.blank?
    
  end
  
  def is_date(date_state)
    begin
      date_state.to_time
    rescue
      return false
    end
    return true
  end

  def importance_states
    {'0' => I18n.t('rumi.gwbbs.select_item.status.importance'), '1' => I18n.t('rumi.gwbbs.select_item.status.normal')}
  end

  def importance_states_select
    return [
      [I18n.t('rumi.gwbbs.select_item.status.importance'), 0] ,
      [I18n.t('rumi.gwbbs.select_item.status.normal'), 1]
    ]
  end

  def one_line_states
    return [
      [I18n.t('rumi.gwbbs.select_item.oneline_comment.unused'), 0] ,
      [I18n.t('rumi.gwbbs.select_item.oneline_comment.use'), 1]
    ]
  end

  def name_types_select
    return [
      [I18n.t('rumi.gwbbs.select_item.display_user.user_name'), 0] ,
      [I18n.t('rumi.gwbbs.select_item.display_user.section_code'), 1] ,
      [I18n.t('rumi.gwbbs.select_item.display_user.both'), 2]
    ]
  end

  def public_path
    if name =~ /^[0-9]{8}$/
      _name = name
    else
      _name = File.join(name[0..0], name[0..1], name[0..2], name)
    end
    Core.public_path + content_public_uri + _name + '/index.html'
  end

  def public_uri
    content_public_uri + name + '/'
  end

  def content_public_uri
    ""
  end

  def check_digit
    return true if name.to_s != ''
    return true if @check_digit == true

    @check_digit = true

    self.name = Util::CheckDigit.check(format('%07d', id))
    save
  end
  
  def self.search(params,item=nil)
    doc_arel_table = self.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'cat1'
        and_cond << doc_arel_table[:category1_id].eq(v)
      when 'cat2'
        and_cond << doc_arel_table[:category2_id].eq(v)
      when 'cat3'
        and_cond << doc_arel_table[:category3_id].eq(v)
      when 'grp'
        and_cond << doc_arel_table[:section_code].eq(v) unless item == 'form007' unless item =='form006'
        and_cond << doc_arel_table[:inpfld_002].eq(v) if item == 'form006'
        and_cond << doc_arel_table[:inpfld_002].eq(v) if item == 'form007'
      when 'yyyy'
        and_cond << doc_arel_table[:inpfld_006w].eq(v) if item == 'form006'
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
      #作成者を検索条件に追加
      when 'creater'
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
      #公開日を検索条件に追加
      when 'startdate'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:able_date].gteq(value+" 00:00:00")
      when 'enddate'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:able_date].lteq(value+" 23:59:59")
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

  # === 作成者検索の条件追加用メソッド
  #  作成者検索の条件を追加するメソッドである。
  # 　掲示板の作成者名と作成者所属名から検索を行い、入力値と部分一致する掲示板を抽出する。
  # ==== 引数
  #  * params: アクションパラメータ
  # ==== 戻り値
  #  作成者検索条件のConditionオブジェクトを戻す
  def search_creator(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      #作成者を検索条件に追加
      when 'creater'
        cond = Condition.new
        quote_string = connection.quote_string(v).gsub(/([_%])/, '\\\\\1')
        cond.and do |c|
          # == 作成者名での部分一致検索条件 ==
          c.or :creater, 'LIKE', "%#{quote_string}%"

          # == 所属名での部分一致検索条件 ==
          # 所属名で部分一致するSystem::Groupを取得
          groups = System::Group.where("name LIKE '%#{quote_string}%'")

          # 所属コード配列を取得
          # ※Gwbbs::Doc.createrdivision_idには所属コードが登録されているので
          # 　検索条件には所属コードを使用する
          group_codes = groups.map(&:code)
          c.or :createrdivision_id, group_codes
        end

        self.and cond
      end
    end if params.size != 0

    return self
  end

  def importance_name
    return self.importance_states[self.importance.to_s]
  end

  def new_comment_path
    return self.item_home_path + "comments/new?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def image_edit_path
    return self.item_home_path + "images?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def upload_edit_path
    return self.item_home_path + "uploads?title_id=#{self.title_id}&p_id=#{self.id}"
  end

  def item_path
    return "/gwbbs/docs?title_id=#{self.title_id}"
  end

  def show_path
    return "/gwbbs/docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def edit_path
    return "/gwbbs/docs/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def adms_edit_path
    return self.item_home_path + "adms/#{self.id}/edit/?title_id=#{self.title_id}"
  end

  def recognize_update_path
    return "/gwbbs/docs/#{self.id}/recognize_update?title_id=#{self.title_id}"
  end

  def publish_update_path
    return "/gwbbs/docs/#{self.id}/publish_update?title_id=#{self.title_id}"
  end

  def clone_path
    return "/gwbbs/docs/#{self.id}/clone/?title_id=#{self.title_id}"
  end
  #
  def adms_clone_path
    return self.item_home_path + "adms/#{self.id}/clone/?title_id=#{self.title_id}"
  end

  def delete_path
    return "/gwbbs/docs/#{self.id}/delete?title_id=#{self.title_id}"
  end

  def update_path
    #return "/_admin/gwbbs/docs/#{self.id}/update?title_id=#{self.title_id}"
    return "/gwbbs/docs/#{self.id}?title_id=#{self.title_id}"
  end

  def portal_show_path
    return self.item_home_path + "docs/#{self.id}/?title_id=#{self.title_id}"
  end

  def portal_index_path
    return self.item_home_path + "docs?title_id=#{self.title_id}"
  end

  def get_domain
    rails_env = ENV['RAILS_ENV']
    ret = 'localhost'
    begin
      site = YAML.load_file('config/core.yml')
      ret = site[rails_env]['domain']
    rescue
    end
    return ret
  end

  def title_update_save
    return if self._no_validation

    sql = "SELECT SUM(LENGTH(`body`)) AS total_size FROM `gwbbs_docs` WHERE title_id = #{self.title_id} GROUP BY title_id"
    item = Gwbbs::Doc.find_by_sql(sql)
    total_size = 0
    total_size = item[0].total_size unless item[0].total_size.blank? unless item.blank?
    item = Gwbbs::Control.find(self.title_id)
    item.doc_body_size_currently  = total_size
    item.docslast_updated_at = Time.now if self.state=='public'   #記事の最終更新日時設定
    item.save(:validate=>false)
  end

  #記事削除時に記事本文のサイズを集計
  def doc_body_size_currently_update
    sql = "SELECT SUM(LENGTH(`body`)) AS total_size FROM `gwbbs_docs` WHERE title_id = #{self.title_id} GROUP BY title_id"
    item = Gwbbs::Doc.find_by_sql(sql)
    total_size = 0
    total_size = item[0].total_size unless item[0].total_size.blank? unless item.blank?
    item = Gwbbs::Control.find(self.title_id)
    item.doc_body_size_currently  = total_size
    item.save
  end

  #終了日を設定しない場合に上限日をセットする
  def expiry_date_update
    if self.inpfld_001 == "1"
      self.expiry_date = "9999-12-31 23:59:59"
    else
      self.inpfld_001 = nil
    end
  end

  def _execute_sql(strsql)
    return self.class.connection.execute(strsql)
  end

  def new_mark_flg
    flg = false
    if self.createdate.blank?
      #flg = false
    else
      begin
        new_mark_start = Time.parse(self.createdate) + 86400
        time_now = Time.now
        if new_mark_start >= time_now
          flg = true
        else
          #flg = false
        end
      rescue
        #flg = false
      end
    end
    return flg
  end

  # === 新着情報(新規作成時)を作成するメソッド
  #  参加者(作成者以外)のユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  boolean true: 成功 false: 失敗
  def build_created_remind
    # 閲覧、編集、管理権限を持つユーザーに通知する
    group_ids = []
    user_ids = []
    control.role.each do |role|
      group_ids << role.group_id
      user_ids << role.user_id
    end
    
    groups = System::Group.where(id: group_ids)
    groups.each do |group|
      group_children = group.enabled_children
      group_children.each do |children|
        group_ids << children.id
      end
    end
    
    group_ids = group_ids.flatten.compact.uniq

    # 制限なしが選択されていた場合
    if group_ids.include?(0)
      send_group_ids = System::Group.all.to_a.map(&:id)
    else
      send_group_ids = group_ids
    end

    # 所属からユーザー通知するユーザーを抽出
    user_ids << build_remind_user_ids(send_group_ids)
    user_ids = user_ids.flatten.compact.uniq
    
    return false if user_ids.blank? 
    
    # ユーザーに通知
    build_remind(user_ids)

    # 更新者は通知を既読にする
    seen_remind(Core.user.id)
    
    return true
  end

  # === 新着情報(編集時)を作成するメソッド
  #  参加者(作成者以外)のユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  boolean true: 成功 false: 失敗
  def build_updated_remind
    # 閲覧、編集、管理権限を持つユーザーに通知する
    group_ids = []
    user_ids = []
    control.role.each do |role|
      group_ids << role.group_id
      user_ids << role.user_id
    end
    group_ids = group_ids.flatten.compact.uniq

    groups = System::Group.where(id: group_ids)
    groups.each do |group|
      group_children = group.enabled_children
      group_children.each do |children|
        group_ids << children.id
      end
    end
    
    # 制限なしが選択されていた場合
    if group_ids.include?(0)
      send_group_ids = System::Group.all.to_a.map(&:id)
    else
      send_group_ids = group_ids
    end

    # 所属からユーザー通知するユーザーを抽出
    user_ids << build_remind_user_ids(send_group_ids)
    user_ids = user_ids.flatten.compact.uniq
    
    return false if user_ids.blank? 

    # ユーザーに通知
    build_remind(user_ids, "update")

    # 更新者は通知を既読にする
    seen_remind(Core.user.id)
    
    return true
  end

  # === 新着情報(コメント時)を作成するメソッド
  #  記事管理課に所属するユーザーに対して作成する
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def build_reply_remind(comment_id)
    target_users_groups = []
    groups = System::Group.where(code: section_code)
    groups.each do |group|
      target_users_groups << group.id
      group_children = group.enabled_children
      group_children.each do |children|
        target_users_groups << children.id
      end
    end
    
    target_users = build_remind_user_ids(target_users_groups)
    target_users.flatten.compact.uniq

    comments = Gwbbs::Comment.where(parent_id: self.id, id: comment_id, title_id: title_id).first
    unread_comments = Gw::Reminder.where(category: 'bbs', sub_category: comments.id, action: "reply")
                                 .where(item_id: self.id, title_id: title_id)
                                 .where("seen_at is null")
    unread_comment_ids = unread_comments.map(&:user_id)

    #target_user = System::User.where(code: creater_id).first
    target_users.each do |target_user|
      next if target_user == Core.user.id
      unless unread_comment_ids.find{|x| x == target_user}
        Gw::Reminder.create!(category: 'bbs',
                             sub_category: comments.id,
                             user_id: target_user,
                             title_id: title_id,
                             item_id: id,
                             title: title,
                             datetime: Time.now(),
                             action: "reply",
                             url: "/gwbbs/docs/#{id}/?title_id=#{title_id}",
                             expiration_datetime: self.class.connection.quote(expiry_date))
      end
    end
  end

  # === 新着情報を作成するユーザーIDの一覧を取得するメソッド
  #  グループに対して作成する
  # ==== 引数
  #  * group_ids: 対象となるグループIDの配列
  # ==== 戻り値
  #  ユーザーIDの配列
  def build_remind_user_ids(group_ids)
    user_ids = System::User.includes(:groups).
      where("system_users.state" => "enabled").
      where(["system_groups.id IN (?)", group_ids]).references(:groups).map(&:id)
    return user_ids.flatten.compact.uniq
  end

  # === 新着情報を作成するメソッド
  #  ユーザーに対して作成する
  # ==== 引数
  #  * user_ids: ユーザーIDの配列
  # ==== 戻り値
  #  なし
  def build_remind(user_ids, action = "open")
    timestamp = self.class.connection.quote(Time.now.utc)
    values = user_ids.collect { |user_id|
      attrs = [
        "'bbs'", user_id, title_id, id, "'#{title.gsub("'", "\\\\'")}'",
        self.class.connection.quote(able_date),
        "'/gwbbs/docs/#{id}/?title_id=#{title_id}'",
        "'#{action}'", timestamp, timestamp,
        self.class.connection.quote(expiry_date),
      ]
      "(#{attrs.join(',')})"
    }
    unless values.blank?
      sql =<<SQL
INSERT INTO #{Gw::Reminder.table_name}
  (category, user_id, title_id, item_id, title, datetime, url,
   action, created_at, updated_at, expiration_datetime)
  VALUES #{values.join(",")}
SQL
      Gw::Reminder.connection.execute(sql)
    end
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
    reply_reminders = Gw::Reminder.where(category: "bbs", title_id: self.title_id)
                                  .where(user_id: user_id, action: 'reply')
                                  .where(item_id: self.id)

    reply_reminders.each do |reminder|
      # 既読にする
      reminder.seen
    end
  end

  # === 未読か評価するメソッド(コメント以外)
  #  ユーザーに対して実行する
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  boolean true: 未読あり false: 全て既読
  def unseen?(user_id)
    reminders.extract_user_id(user_id).extract_not_reply.exists?
  end
  
  # === 未読か評価するメソッド(コメント)
  #  ユーザーに対して実行する
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  boolean true: 未読あり false: 全て既読
  def comment_unseen?(user_id)
    reminders.extract_user_id(user_id).extract_reply.exists?
  end

  # === 記事が公開状態、かつ公開期限内であるか評価するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  boolean true: public / false: それ以外
  def public_status?
    return state == "public"
  end

end

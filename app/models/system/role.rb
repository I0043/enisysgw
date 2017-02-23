# encoding: utf-8
#require 'digest/sha1'
class System::Role < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Base::Content

  validates_presence_of :idx, :class_id, :uid

  validates_numericality_of :idx

  validates_uniqueness_of :uid, message: I18n.t("rumi.role.message.overlap"), on: :create

  belongs_to :role_name  ,:class_name=>'System::RoleName'
  belongs_to :priv_user  ,:class_name=>'System::PrivName'
  belongs_to :user,  -> {where('class_id = 1')}, :foreign_key=>:uid,:class_name=>'System::User'
  belongs_to :group, -> {where('class_id = 2')}, :foreign_key=>:uid,:class_name=>'System::Group'

  has_many :editable_groups, foreign_key: :system_role_id, class_name: "System::RoleGroup", dependent: :destroy

  before_save :before_save_setting_columns, :before_save_editable_groups_json
  after_save :save_editable_groups

  def self.is_admin?(uid = Core.user.id)
    Gw.is_admin_admin?
  end

  def before_save_setting_columns
    unless self.role_name_id.nil?
      self.table_name = "_admin" unless self.role_name_id.blank?
    end
    unless self.priv_user_id.nil?
      self.priv_name = "admin" unless self.priv_user_id.blank?
    end
  end

  # === レコード保存前にユーザー・グループ管理、運用管理者ではない場合はJSONを空にするメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def before_save_editable_groups_json
    role = System::RoleName.system_users_role
    priv = System::PrivName.editor

    if (role && priv) && (role_name_id && priv_user_id)
      unless (role.id == role_name_id) && (priv.id == priv_user_id)
        self.editable_groups_json = nil
      end
    end
  end

  # === レコード保存後に管理グループレコードを生成するメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  なし
  def save_editable_groups
    editable_groups.destroy_all

    if editable_groups_json.present?
      system_role_id = id
      group_infos = JsonParser.new.parse(editable_groups_json)
      group_infos.each do |group_info|
        next if group_info[1].blank?
        role_group_attrs = { system_role_id: system_role_id, role_code: "w" }
        # 制限なしの場合
        if group_info[1].to_s == "0"
          role_group_attrs.merge!({
            group_code: "0", group_id: "0",
            group_name: group_info[2]})
        else
          origin_group = System::Group.where(id: group_info[1]).first
          role_group_attrs.merge!({
            group_code: origin_group.try(:code), group_id: origin_group.try(:id),
            group_name: origin_group.try(:name)})
        end
        role_group = System::RoleGroup.new(role_group_attrs)
        role_group.save! if role_group.group_code.present?
      end
    end
  end

  def role_classes
     Gw.yaml_to_array_for_select('system_role_classes')
  end

  def users
    users_raw = System::User.all
    users_list = users_raw.collect{|x|[x['id'], x['name']]}
    return users_list
  end

  def groups
    items_raw = System::Group.order('code')
    items = []
    items_raw.each do |item_raw|
      items.push [item_raw['id'], item_raw['name']]
    end
    return items
  end

  def privs
    Gw.yaml_to_array_for_select('t1f0_kyoka_fuka')
  end

  def get(table_name, priv_name)
    self.order('idx').where( :table_name => table_name, :priv_name => priv_name )
  end

  def self.td_criteria
    {
      'uid' => Proc.new{|item|
        case item.class_id
        when 1
          "#{Gw::Model::Schedule.get_uname :uid=>item.uid}"
        when 2
          "#{Gw::Model::Schedule.get_gname :gid=>item.uid}"
        else
          ''
        end
      }
    }
  end

  def self.search(params)
    condition = Condition.new()
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'role_id'
        unless (v.to_s == '0' || v.to_s == nil)
          condition.and do |cond|
            w1 = v.to_s
            cond.or :role_name_id, '=', "#{w1.to_i}"
          end
        end
      when 'priv_id'
        unless (v.to_s == '0' || v.to_s == nil)
          condition.and do |cond|
            w1 = v.to_s
            cond.or :priv_user_id, '=', "#{w1.to_i}"
          end
        end
      end
    end if params.size != 0
    return condition
  end

  def class_id_no
    [[I18n.t("rumi.role.radio.all"), 0], [I18n.t("rumi.role.radio.user"), 1], [I18n.t("rumi.role.radio.group"), 2]]
  end

  def class_id_label
    class_id_no.each {|a| return a[0] if a[1] == class_id }
    return nil
  end

  def priv_no
    [[I18n.t("rumi.role.radio.parmit"), 1],[I18n.t("rumi.role.radio.improper"), 0]]
  end

  def priv_label
    priv_no.each {|a| return a[0] if a[1] == priv }
    return nil
  end

  def uid_label
    label = ''
      case self.class_id
      when 1
        label = Gw::Model::Schedule.get_uname :uid=>self.uid
      when 2
        label = Gw::Model::Schedule.get_gname :gid=>self.uid
      end
    return label
  end
  
  def group_name
    name = ''
    group = System::Group.where(id: self.group_id).first
    name = group.name if group.present?
    return name
  end

  def user_name
    name = ''
    user = System::User.where(id: self.uid).first
    name = user.name if user.present?
    return name
  end

  def editable?
      return true
  end

  def deletable?
    if self.table_name.to_s == "_admin"
      # GW管理画面の管理者（システム管理者）が１名の場合は削除不可
      c_priv = "table_name='_admin' and priv_name='admin'"
      count = System::Role.where(c_priv).count(:all)
      return false if count.to_i < 2
      return true
    else
      return true
    end
  end

  # === 優先順位に基づいて権限判定するメソッド
  #
  # ==== 引数
  #  * user_id: ユーザーID
  #  * table_name: 機能コード
  #  * priv_name: 権限コード
  # ==== 戻り値
  #  boolean
  def self.has_auth?(user_id, table_name = "_admin", priv_name = "admin")
    role = System::User.find(user_id).role(table_name, priv_name)
    # ユーザーが対象に含まれている権限があれば許可／不許可か返す
    return role.priv == 1 if role.present?
    # 権限が設定されていなければ、falseを返す
    return false
  end

end

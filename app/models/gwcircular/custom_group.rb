# -*- encoding: utf-8 -*-
class Gwcircular::CustomGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name
  validates_numericality_of :sort_no, :greater_than_or_equal_to => 0

  after_validation :check_readers

  # === 自分が作成したカスタムグループのみ抽出するためのスコープ
  #
  # ==== 引数
  #  * user_id: ユーザーID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_owner_id_without_disable, lambda { |user_id|
    without_disable.where(owner_uid: user_id).order(:sort_no, :id)
  }

  # === 有効なカスタムグループのみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :without_disable, lambda {
    where(state: "enabled")
  }

  # === 選択UIにて表示する選択肢の作成を行うメソッド
  #
  # ==== 引数
  #  * value_method: Symbol e.g. :code
  # ==== 戻り値
  #  [value, display_name_with_level_no]
  def to_select_option(value_method = :id)
    return [Gw.trim(self.name), self.id]
  end

  def check_readers
    if self.readers_json.blank?
      errors.add :readers_json, I18n.t('rumi.gwcircular.custom_group.message.validate_readers')
    else
      objects = JsonParser.new.parse(self.readers_json)
      if objects.count == 0
        errors.add :readers_json, I18n.t('rumi.gwcircular.custom_group.message.validate_readers')
      end
    end
  end

  def states
    {'enabled' => I18n.t('rumi.gwcircular.custom_group.states.enabled'), 'disabled' => I18n.t('rumi.gwcircular.custom_group.states.disabled')}
  end

  def self.custom_select
    list = []
    Gwcircular::CustomGroup.where(:state => 'enabled', :owner_uid => Core.user.id).order('sort_no,id').each do |dep|
      list << [dep.name, dep.id]
    end
    list = [[I18n.t('rumi.gwcircular.custom_group.custom_select'),""]] if list == []
    return list
  end

  def self.first_group_id
    item = Gwcircular::CustomGroup.extract_owner_id_without_disable(Core.user.id).first
    ret = 0
    ret = item.id unless item.blank?
    return ret
  end

  def self.get_user_select(gid)
    item = Gwcircular::CustomGroup.find_by(id: gid)
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JsonParser.new.parse(item.readers_json)
    users.each do |user|
      selects << [user[2].to_s,user[1].to_s]
    end
    return selects
  end

  def self.get_user_select_ajax(gid)
    item = Gwcircular::CustomGroup.find_by(id: gid)
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JsonParser.new.parse(item.readers_json)
    users.each do |user|
      selects << [user[0].to_s,user[1].to_s,user[2].to_s]
    end
    return selects
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end
end

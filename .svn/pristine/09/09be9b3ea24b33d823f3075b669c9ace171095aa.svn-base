# encoding: utf-8
class Gw::EditLinkPiece < Gw::Database
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Base::Content

  belongs_to :parent, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  has_many :children, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  has_many :opened_children, -> {where("published = 'opened' and state != 'deleted'").order('sort_no')}, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  belongs_to :css, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_css_id
  belongs_to :icon, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_icon_id

  validates_presence_of :name, :sort_no
  validates_presence_of :link_url,
    :if => lambda{|item| item.level_no == 4}
  validates_presence_of :field_account,
    :if => lambda{|item| item.class_sso == 2}
  validates_presence_of :field_pass,
    :if => lambda{|item| item.class_sso == 2}
  validates_presence_of :ssoid,
    :if => lambda{|item| item.class_sso == 2 && item.uid != nil}
  validates_uniqueness_of :sort_no, :scope=>:parent_id
  validate :validate_tab_keys

  # 階層レベル2ならば配置場所は必須かつ、一覧内の値のみ許可する
  validates :location, inclusion: { in: Gw.yaml_to_array_for_select("link_piece_locations").map { |factor| factor.last.to_i } },
    if: Proc.new { |record| record.level_2? }

  before_create :set_creator
  before_update :set_updator

  # === 階層レベル1のみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_root, -> { where(level_no: 1) }

  # === 配置場所がポータル 左のみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_location_left, lambda {
    extract_level_no_2.extract_enable.where(location: 1)
  }

  # === 配置場所がポータル ヘッダのみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_location_header, lambda {
    extract_level_no_2.extract_enable.where(location: 2)
  }

  # === 配置場所がポータル ヘッダのみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_enable, lambda {
    where(published: "opened", state: "enabled").includes(
      [:css, :icon,
        opened_children: [:css, :icon, :parent,
          opened_children: [:css, :icon, :parent]
        ]
      ]).order_sort_no
  }

  # === 階層レベル2のみ抽出するためのスコープ
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :extract_level_no_2, -> { where(level_no: 2) }

  # === 並び替えのスコープ
  #  並び順の昇順
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :order_sort_no, -> { order("gw_edit_link_pieces.sort_no") }

  # === 階層レベル1のレコードIDを返すメソッド
  #
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  レコードID
  def self.root_id
    return Gw::EditLinkPiece.extract_root.first.id
  end

  def self.is_admin?(uid = Core.user.id)
    @gw_admin
  end

  def self.published_select
    published = [[I18n.t("rumi.state.open"), 'opened'],[I18n.t("rumi.state.close"), 'closed']]
    return published
  end

  def self.published_show(published)
    publishes = [['closed', I18n.t("rumi.state.close")],['opened', I18n.t("rumi.state.open")]]
    show_str = publishes.assoc(published)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.state_select
    status = [[I18n.t("rumi.state.enabled"), 'enabled'],[I18n.t("rumi.state.disabled"), 'disabled']]
    return status
  end

  def self.state_show(state)
    status = [['deleted', I18n.t("rumi.state.deleted")],['disabled', I18n.t("rumi.state.disabled")],['enabled', I18n.t("rumi.state.enabled")]]
    show_str = status.assoc(state)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.other_ctrl_select
    other_ctrls = [[I18n.t("rumi.state.use"), 1],[I18n.t("rumi.state.unuse"), 2]]
    return other_ctrls
  end

  def self.other_ctrl_show(other_ctrl)
    other_ctrls = [[1, I18n.t("rumi.state.use")],[2, I18n.t("rumi.state.unuse")]]
    show_str = other_ctrls.assoc(other_ctrl)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.external_select
    externals = [[I18n.t("rumi.state.internal"), 1],[I18n.t("rumi.state.external"), 2]]
    return externals
  end

  def self.external_show(class_external)
    externals = [[1, I18n.t("rumi.state.internal")],[2, I18n.t("rumi.state.external")]]
    show_str = externals.assoc(class_external)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.sso_select
    ssos = [[I18n.t("rumi.state.unuse"), 1],[I18n.t("rumi.state.use"), 2]]
    return ssos
  end

  def self.sso_show(class_sso)
    ssos = [[1, I18n.t("rumi.state.unuse")],[2, I18n.t("rumi.state.unuse")]]
    show_str = ssos.assoc(class_sso)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.level_show(level_no)
    level_str = [[1,I18n.t("rumi.config_settings.edit_link_piece.level_no:l1")],[2,I18n.t("rumi.config_settings.edit_link_piece.level_no:l2")],[3,I18n.t("rumi.config_settings.edit_link_piece.level_no:l3")],[4, I18n.t("rumi.config_settings.edit_link_piece.level_no:l4")]]
    show_str = level_str.assoc(level_no)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def get_child(options={})
    if options[:published]
      cond  = "published = '#{options[:published]}' and state != 'deleted' and parent_id=#{self.id}"
    else
      cond  = "state != 'deleted' and parent_id=#{self.id}"
    end
    order = "sort_no"
    childrens = Gw::EditLinkPiece.where(cond).order(order)
    return childrens
  end

  def parent_tree
    Util::Tree.climb(id, :class => self.class)
  end

  def link_options
    options = {}

    if self.state == 'disabled' || (self.parent && self.parent.state == 'disabled')
      options[:url] = "#void"
      options[:disabled] = 'grayout'
    else
      if self.class_sso == 2
        options[:url] = "/_admin/gw/link_sso/#{self.id}/redirect_pref_pieces"
      else
        options[:url] = self.link_url
      end
    end

    if self.class_external == 2
      options[:target] = '_blank';
    else
      options[:target] = '_self';
    end

    if self.css && self.css.state == 'enabled'
      options[:css_class] = self.css.css_class
    end

    if self.icon && self.icon.state == 'enabled'
      options[:icon_class] = self.icon.css_class
    end

    if self.icon_path.present? && FileTest.exist?(Rails.root.join("public/#{self.icon_path}"))
      options[:icon_path] = self.icon_path
    end

    options
  end

  def deleted?
    return self.state == 'deleted'
  end

  def has_display_auth?
    if self.display_auth.present?
      begin
        return eval(self.display_auth)
      rescue SyntaxError, ScriptError, StandardError
        return false
      end
    end
    return true
  end

  def self.swap(item1, item2)
    item1.sort_no, item2.sort_no = item2.sort_no, item1.sort_no
    item1.save(:validate => false)
    item2.save(:validate => false)
  end

  # === 階層レベル2か判断するメソッド
  #  グループの並び順 > グループコード昇順
  # ==== 引数
  #  * なし
  # ==== 戻り値
  #  boolean
  def level_2?
    return self.level_no == 2
  end

protected

  def validate_tab_keys
    unless self.level_no == 2
      return true
    end
    if self.tab_keys.blank? || self.tab_keys == 0
      errors.add :tab_keys, I18n.t("rumi.error.not_zero")
      return false
    end
    cond = "level_no=2 and tab_keys=#{self.tab_keys}"
    check = Gw::EditLinkPiece.where(cond)
    if check.blank?
      return true
    else
      if check.size==1 and check[0].id==self.id
        return true
      end
      errors.add :tab_keys, I18n.t("rumi.error.registered")
      return false
    end
    return true
  end

  def set_creator
    self.created_user   = Core.user.name
    self.created_group  = Core.user_group.name
  end

  def set_updator
    self.updated_user   = Core.user.name
    self.updated_group  = Core.user_group.name
  end
end
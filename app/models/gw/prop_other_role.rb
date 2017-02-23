# encoding: utf-8
class Gw::PropOtherRole < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop_other,  :foreign_key => :prop_id,     :class_name => 'Gw::PropOther'
  belongs_to :group,       :foreign_key => :gid,         :class_name => 'System::Group'

  def self.get_search_select(pattern, is_gw_admin, gid = Core.user_group.id)

    items = self.where("auth = '#{pattern}' ").group("gid").order("gid")

    prop_list = [[I18n.t("rumi.select.all"),'']]
    prop_list << [I18n.t("rumi.select.no_limit"),'0'] if pattern == "edit"
    prop_list << [I18n.t("rumi.select.no_limit"),'0'] if pattern == "read"
    items.each do |item|
      unless item.group.blank?
        if is_gw_admin || pattern == "admin"
          prop_list << [item.group.name , item.gid]
        elsif  !is_gw_admin && (pattern == "edit" ||  pattern == "read")
          prop_list << [item.group.name , item.gid] if is_admin?(item.prop_id, gid)
        end
      end
    end

    return prop_list
  end

  def self.admin_group_count( gid = Core.user_group.id )
    p_cond  = "gw_prop_other_roles.gid = #{gid} and gw_prop_other_roles.auth = 'admin' and gw_prop_others.delete_state=0 "
    p_joins = "LEFT JOIN gw_prop_others ON gw_prop_others.id = gw_prop_other_roles.prop_id"
    ret = self.select("gw_prop_other_roles.id").where(p_cond).joins(p_joins)
    return ret.size
  end

  def self.is_admin?(prop_id, gid = Core.user_group.id )
    ret = self.where(prop_id: prop_id, gid: search_ids, auth: "admin")
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_edit?(prop_id)
    ret = self.where(prop_id: prop_id, gid: search_ids, auth: "edit")
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.is_read?(prop_id)
    ret = self.where(prop_id: prop_id, gid: search_ids, auth: "read")
    if ret.size > 0
      return true
    else
      return false
    end
  end

  def self.search_ids
    groups = Core.user.groups
    gids = Array.new
    groups.each do |sg|
      gids << sg.id
      gids << sg.parent_id
    end
    gids << 0
    gids.uniq!
    return gids
  end
end

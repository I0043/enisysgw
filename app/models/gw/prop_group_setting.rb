# encoding: utf-8
class Gw::PropGroupSetting < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :prop_other,  :foreign_key => :id, :class_name => 'Gw::PropOther'
  belongs_to :prop_group, :foreign_key => :id, :class_name => 'Gw::PropGroup'

  def self.getajax(params)
    #施設マスタ権限を持つユーザーかの情報
    admin = Gw.is_admin_admin?

    item = Gw::PropOther.where(type_id: params[:type_id], delete_state: 0)
                        .order("type_id, gid, sort_no, name")
                        .select{|x| true if admin}
                        .collect{|x| ["other", x.id, "(" + System::Group.find(x.gid).name.to_s + ")" + x.name.to_s, x.gname]}
    item = {errors: I18n.t("rumi.ajax.message.no_hit")} if item.blank?
    return item
  end
end

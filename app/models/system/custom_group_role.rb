# encoding: utf-8
class System::CustomGroupRole < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config

  self.primary_key = 'rid'

  belongs_to :custom_group,  :foreign_key => :custom_group_id,     :class_name => 'System::CustomGroup'
  belongs_to :group       ,  :foreign_key => :group_id       ,     :class_name => 'System::Group'
  belongs_to :user        ,  :foreign_key => :user_id        ,     :class_name => 'System::User'

  def self.editable?( cgid, gid, uid )
    groups = System::UsersGroup.where(user_id: Core.user.id).pluck(:group_id)
    class_id = System::CustomGroupRole.arel_table[:class_id]
    group_id = System::CustomGroupRole.arel_table[:group_id]
    user_id = System::CustomGroupRole.arel_table[:user_id]

    ret = System::CustomGroupRole.where(custom_group_id: cgid)
                                 .where((class_id.eq(2).and(group_id.in(groups))).or(class_id.eq(1).and(user_id.eq(uid))))
                                 .where(priv_name: "edit")
    return ret.size > 0
  end

end

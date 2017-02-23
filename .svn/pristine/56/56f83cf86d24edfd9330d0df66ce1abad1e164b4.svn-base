# encoding: utf-8
class System::LdapTemporary < ActiveRecord::Base
  include System::Model::Base

  def synchro_target?
    return true
  end

  def children
    tmp = System::LdapTemporary.where(version: self.version, parent_id: self.id, data_type: 'group').order(:code)
    return tmp
  end

  def users
    tmp = System::LdapTemporary.where(version: self.version, parent_id: self.id, data_type: 'user').order(:code)
    return tmp
  end
end

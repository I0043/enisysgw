module Gwcircular::Controller::Authorize

  def parent_group_code
    item = System::Group.find_by(id: Core.user_group.parent_id) if Core.user_group.parent_id
    ret = item.code if item
    return ret
  end

  def get_editable_flag(item)
    @is_editable = true if @gw_admin
    unless @is_editable
      get_writable_flag
      @is_editable = true if item.target_user_code == Core.user.code if @is_writable
      @is_editable = false if item.state == 'preparation'
    end
  end

  def get_role_index
    get_readable_flag
    get_writable_flag
  end

  def get_role_show(item)
    get_readable_flag
    get_editable_flag(item)
  end

  def get_role_edit(item)
    get_editable_flag(item)
  end

  def get_role_new
    get_writable_flag
  end

  def is_authorized(item)
    _compare = false
    unless item.blank?
      if authorized_person_only(item)
        _compare = true
      else
        _compare = true if @title.state == 'public'
      end
    end
    return _compare
  end

  def authorized_person_only(item)
    _compare = false
    unless item.creator.nil?
      _compare = true if Core.user.code == item.creater_id
    end
    return _compare
  end
end

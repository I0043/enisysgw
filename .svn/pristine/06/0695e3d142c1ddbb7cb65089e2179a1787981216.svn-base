module Gwboard::Model::DbnameAlias

  def gwboard_control
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::Control
    when 'doclibrary'
      sys = Doclibrary::Control
    else
    end
    return sys
  end

  def gwboard_file
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::File
    when 'doclibrary'
      sys = Doclibrary::File
    else
    end
    return sys
  end

   def gwboard_file_close
    case params[:system]
    when 'gwbbs'
      sys = Gwbbs::File
    when 'doclibrary'
      sys = Doclibrary::File
    else
    end
    #sys.remove_connection
  end
  #

  def get_readable_flag
    
    case params[:system]
      when 'gwbbs'
        @is_readable = true if @gw_admin
        unless @is_readable
          sql = Condition.new
          sql.and :role_code, 'r'
          sql.and :title_id, @title.id
          sql.and 'sql', 'user_id IS NULL'
          items = Gwbbs::Role.order('group_code').where(sql.where)
          items.each do |item|
            @is_readable = true if item.group_code == '0'
            for user_group in Core.user.enable_user_groups
              @is_readable = true if item.group_code == user_group.group_code
              @is_readable = true if item.group_code == user_group.group.parent.code unless user_group.group.parent.blank?
              break if @is_readable
            end
            break if @is_readable
          end
        end

        unless @is_readable
          item = Gwbbs::Role.where(role_code: 'r', title_id: @title.id, user_code: Core.user.code).first
          @is_readable = true if item.user_code == Core.user.code unless item.blank?
        end
      when 'doclibrary'
        @doclibrary_admin = @gw_admin
        unless @doclibrary_admin
          items = Doclibrary::Adm.where(user_id: 0, group_id: Core.user.user_group_parent_ids)
          items = items.where(title_id: @title.id) unless @title.id == '_menu'
          @doclibrary_admin = true unless items.blank?

          unless @doclibrary_admin
            items = Doclibrary::Adm.where(user_id: Core.user.id)
            items = items.where(title_id: @title.id) unless @title.id == '_menu'
            @doclibrary_admin = true unless items.blank?
          end
        end
        @is_readable = @gw_admin || @doclibrary_admin
        unless @is_readable
          users_groups = System::UsersGroup.where(user_id: Core.user.id).where("end_at is null")
          groups = System::Group.where(id: users_groups.map(&:group_id))
          group_ids = []
          group_ids << 0
          groups.each do |group|
            group_ids << group.id
            group_ids << group.parent_id
          end
          g_read = Doclibrary::Role.where(title_id: @title.id, role_code: "r", group_id: group_ids)
          @is_readable = true if g_read.present?

          u_read = Doclibrary::Role.where(title_id: @title.id, role_code: "r", user_id: Core.user.id)
          @is_readable = true if u_read.present?
        end
      else
    end
  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

end
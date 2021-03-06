# encoding: utf-8
class Gw::ScheduleUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

  def schedule_before_destroy
    fields = Array.new
    values = Array.new

    self.class.columns.each do |column|
      fields << "`#{column.name}`"

      column_data = nz(eval("self.#{column.name}"), "null")
      if column_data == 'null'
        values << "#{column_data}"
      elsif column.type == :datetime
        column_data = column_data.strftime("%Y-%m-%d %H:%M:%S")
        values << "'#{column_data}'"
      else
        values << "'#{column_data}'"
      end
    end

    fields << "`destroy_at`"
    values << "'#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    fields << "`destroy_uid`"
    values << "'#{Core.user.id}'"

    sql_fields = fields.join(',')
    sql_values = values.join(',')
    sql = "INSERT INTO gw_destroy_schedule_users (#{sql_fields}) VALUES (#{sql_values})"

    self.class.connection.execute(sql)
  end

  def get_object
    case class_id
    when 1
      self.user
    when 2
      self.group
    end
  end

  def get_object_name
    case class_id
    when 1
      "#{self.user.name} (#{self.user.code})"
    when 2
      self.group.name
    end
  end

  def self.user_exist_check(schedule_id = nil, uid = Core.user.id)
    return false if schedule_id.blank?
    item = Gw::ScheduleUser.where("schedule_id = #{schedule_id} and class_id = 1 and uid = #{uid}").first

    if item.blank?
      return false
    else
      return true
    end
  end

  def self.users_view(items, options = {})
    caption = nz(options[:caption])
    include_table_tag = true if options[:include_table_tag].nil?

    ret = ''
    ret.concat '<table class="show">' if include_table_tag
    ret.concat %Q(<tr><th colspan="2">#{caption}</th></tr>) if caption
    items.each do |x|
      begin
        case x.class_id
        when 0
          th = I18n.t("rumi.schedule_user.view.all")
          td = ''
        when 1
          th = I18n.t("rumi.schedule_user.view.user")
          user = System::User.where("id=#{x.uid}").first
          if user.blank? || user.state != 'enabled'
            td = ''
          else
            td = user.display_name
          end

        when 2
          th = I18n.t("rumi.schedule_user.view.group")
          group = System::Group.where("id=#{x.uid}").first
          if group.blank? || group.state != 'enabled'
            td = ''
          else
            td = group.name
          end

        end
        ret.concat "<tr><th>#{th}</th><td>#{td}</td></tr>" unless td.blank?
      rescue
      end
    end
    ret.concat '</table>' if include_table_tag
    return ret
  end

  # === 閲覧画面用View作成メソッド
  def self.users_state_view(item, options = {})
    include_table_tag = true if options[:include_table_tag].nil?

    ret = ''
    ret.concat '<table class="defaultTable">' if include_table_tag
    caption1 = I18n.t("rumi.schedule.schedule_user.state")
    caption2 = I18n.t("rumi.schedule.schedule_user.add_user")
    if options[:m_type] == "smart"
      ret.concat %Q(<tr><th class="state">#{caption1}</th><th>#{caption2}</th></tr>)
    else
      ret.concat %Q(<tr><th style="width:135px;">#{caption1}</th><th>#{caption2}</th></tr>)
    end
    item.schedule_users.each do |x|
      begin
        user = System::User.where("id=#{x.uid}").first
        if user.blank? || user.state != 'enabled'
          user_name = ''
        else
          user_name = user.display_name_only
        end
        if item.unseen?(x.uid)
          class_str = "required"
          is_state = I18n.t("rumi.schedule.schedule_user.state_unread")
        else
          if item.seen_at(x.uid)
            class_str = "notice"
            is_state = I18n.t("rumi.schedule.schedule_user.state_already")
          else
            # 新着情報レコードが存在しない場合、既読と見なす。
            class_str = "notice"
            is_state = I18n.t("rumi.schedule.schedule_user.state_already")
          end
        end
        ret.concat %Q(<tr><td class=#{class_str}>#{is_state}</td><td>#{user_name}</td></tr>) unless user_name.blank?
      rescue
      end
    end
    ret.concat '</table>' if include_table_tag
    return ret
  end
end

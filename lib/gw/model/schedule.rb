# encoding: utf-8
module Gw::Model::Schedule

  def self.remind
    item = Gw::Schedule
    d = Date.today
    items = item.order('st_at, ed_at').joins(:schedule_users).where("gw_schedule_users.class_id = 1 and gw_schedule_users.uid = #{Core.user.id}" +
                    " and (#{Gw.date_between_helper :st_at, d, d+2} or #{Gw.date_between_helper :ed_at, d, d+2})")
    ret_ary = []
    items.each do |x|
      date_str = "#{x.st_at.strftime("%m/%d %H:%M")}-" +
        ( x.st_at.strftime("%m/%d") != x.ed_at.strftime("%m/%d") ? x.ed_at.strftime("%m/%d ") : '' ) +
        x.ed_at.strftime("%H:%M")
      title_str = %Q[<a href="/gw/schedules/#{x.id}/show_one">#{x.title}</a>]
      if x.creator_uid != Core.user.id
        uw = System::User.where("id=#{x.creator_uid}").first
        title_str.concat " (#{uw.groups[0].name.strip} #{uw.name.strip})"
      end
      ret_ary.push({:date_str => date_str,
        :cls => I18n.t("rumi.smart.schedule.name"),
        :title => title_str})
    end
    return ret_ary
  end

  def self.show_schedule_move_core(ab, my_url, qs)
    ret = ""
    ab.each_with_index do |x, id|
      href = my_url.sub('%d', "#{(x[0]).strftime('%Y%m%d')}").sub('%q', "#{qs}")
      ret.concat ' ' if id != 0
      ret.concat %Q(<li><a href="#{href}">#{x[1]}</a></li>)
    end
    return ret
  end

  def self.smart_show_schedule_move_core(ab, my_url, qs)
    ret = ""
    ab.each_with_index do |x, id|
      href = my_url.sub('%q', "#{qs}").sub('%d', "#{(x[0]).strftime('%Y%m%d')}")

      ret.concat ' ' if id != 0
      if x[1] == I18n.t("rumi.smart.schedule.move_core.last_week")
        ret.concat %Q(<li><a href="#{href}" class="last_week">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.yesterday")
        ret.concat %Q(<li><a href="#{href}" class="yesterday">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.today")
        ret.concat %Q(<li><a href="#{href}" class="today">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.tomorrow")
        ret.concat %Q(<li><a href="#{href}" class="tomorrow">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.following_week")
        ret.concat %Q(<li><a href="#{href}" class="following_week">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.last_year")
        ret.concat %Q(<li><a href="#{href}" class="last_year">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.last_month")
        ret.concat %Q(<li><a href="#{href}" class="last_month">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.this_month")
        ret.concat %Q(<li><a href="#{href}" class="this_month">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.following_month")
        ret.concat %Q(<li><a href="#{href}" class="following_month">#{x[1]}</a></li>)
      elsif x[1] == I18n.t("rumi.smart.schedule.move_core.following_year")
        ret.concat %Q(<li><a href="#{href}" class="following_year">#{x[1]}</a></li>)
      else
        ret.concat %Q(<li><a href="#{href}">#{x[1]}</a></li>)
      end
    end
    return ret
  end

  def self.get_user(uid)
    System::User.where("id=#{uid}").first
  end

  def self.get_users_id_in_group(gid)
    return [] unless System::Group.where("id=#{gid}").first
    return System::UsersGroup.where("group_id=#{gid}").joins(:user).order("code").reject{|x| x.user.state != 'enabled'}.collect{|x| x.user_id }
  end

  def self.get_uids(params)
    if params[:gid].present?
      gid = params[:gid]
      if gid =='me'
        gid = Core.user.groups[0].id
      elsif /^\d+$/ !~ gid
        return []
      end
      uids = get_users_id_in_group(gid)
      uids = [Core.user.id] if uids.length == 0
    elsif params[:cgid].present?
      cgid = params[:cgid]
      uids = System::UsersCustomGroup.where("custom_group_id = #{cgid}").order("sort_no").collect{|x| x.user_id }
    else
      uid = params[:uid]
      uid = Core.user.id if uid.nil? || uid == 'me'
      if uid == 'all'
        return System::User.where("state='enabled'").collect{|x| x.id}, nil
      end
      uid = uid.to_i rescue Core.user.id
      uid = Core.user.id if System::User.where("id=#{uid}").length == 0
      uids = [uid]
    end
    return uids
  end

  def self.get_users(params)
    if params[:gid].present?
      gid = params[:gid]
      if gid =='me'
        gid = Core.user.groups[0].id
      elsif /^\d+$/ !~ gid
        return []
      end

      users = System::User.where("system_users_groups.group_id=? AND system_users.state = 'enabled' AND system_users_groups.end_at is null", gid)
                          .joins(:user_groups)
                          .order("system_users.sort_no, system_users.code")

    elsif params[:cgid].present?

      cgid = params[:cgid]
      if /^\d+$/ !~ cgid
        return []
      end

      custom_group = System::CustomGroup.where(id: cgid).first
      user_ids = custom_group.user_custom_group.order("system_users_custom_groups.sort_no").map(&:user_id)
      users = user_ids.map do |user_id|
        System::User.without_disable.where(id: user_id).first
      end
      users.compact!
    elsif params[:uid].present?
      users = System::User.where("id = ? and state = 'enabled'", params[:uid])
    else
      users = [Core.user]
    end
    return users
  end

  def self.get_uname(options={})
    case
    when !options[:uid].nil?
      ux = System::User.where("id=#{options[:uid]}").first
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name_only))
    else
      return ''
    end
  end

  def self.get_gname(options={})
    case
    when !options[:gid].nil?
      ux = System::Group.where("id=#{options[:gid]}").first
      return '' if ux.nil?
      return Gw.trim(nz(ux.display_name))
    else
      return ''
    end
  end

  def self.get_group(options={})
    return !options[:gid].nil? ? System::Group.where("id=#{options[:gid]}").first :
      !options[:uid].nil? ? System::User.where("id=#{options[:uid]}").first.groups[0] : nil
  end

  def self.get_prop_ids(params)
    return [] if params[:s_genre].nil?
    if params[:prop_id].nil?
      cond = "delete_state = 0 or delete_state is null"
      _mdl = Gw::PropOther
      _mdl.where(cond).order('extra_flag, gid, sort_no, name').select{|x|
        x.gid.to_s == Core.user.groups[0].id.to_s
      }.collect{|x| x.id}
    else
      [params[:prop_id]]
    end
  end

  def self.get_prop(prop_id, params)
    _mdl = Gw::PropOther
    _mdl.where("id=#{prop_id}").first
  end

  def self.get_props(params, is_gw_admin = Gw.is_admin_admin?, options = {})

    s_other_admin_gid = options[:s_other_admin_gid].to_i
    _mdl = Gw::PropOther
    cond = ""

    cond.concat " delete_state = 0"
    cond_type = ""

    if is_gw_admin
      if options[:type_id].blank?
        cond_type = ""
      elsif params[:type_id] == '0'
      else
        cond_type = " and type_id = #{options[:type_id]}"
      end
    else
      cond_type = " and type_id = #{options[:type_id]}" if options[:type_id].present? && options[:type_id] != '0'
    end
    cond_other = "delete_state = 0 and (auth = 'read' or auth = 'edit')"
    # 自身のすべての所属グループで予約可能所属、照会可能所属のものを取得する
    groups = Core.user.groups
    gids = Array.new
    groups.each do |sg|
      gids << sg.id
      gids << sg.parent_id
    end
    gids << 0
    gids.uniq!
    search_gids = Gw.join([gids], ',')
    cond_other.concat " and (gw_prop_other_roles.gid in (#{search_gids}))"
    cond_other.concat cond_type

    cond_other_admin = ""
    if s_other_admin_gid != 0 # 絞り込み
      s_other_admin_group = System::GroupHistory.find_by(id: s_other_admin_gid)
      s_other_admin_group
      cond_other_admin = "auth = 'admin'"
      if s_other_admin_group.level_no == 2 # 部局
        gids = Array.new
        gids << s_other_admin_gid
        parent_groups = System::GroupHistory.new.select("id").where('parent_id = ?', s_other_admin_gid)
        parent_groups.each do |parent_group|
          gids << parent_group.id
        end
        search_group_ids = Gw.join([gids], ',')
        cond_other_admin.concat " and gw_prop_other_roles.gid in (#{search_group_ids})"
      else # 所属
        cond_other_admin.concat " and gw_prop_other_roles.gid = #{s_other_admin_group.id}"
      end

      if is_gw_admin
        cond_other_admin = " and #{cond_other_admin}"
      else
        cond_other_admin = " and gw_prop_others.id in (select `prop_id` from `gw_prop_other_roles` where #{cond_other_admin})"
      end
    end

    #施設グループに関連付いている施設マスタを抽出する条件を作成
    cond_prop_group = ""
    if options[:prop_group_id].present?
      cond_group_ids = Array.new
      p_cond  = "gw_prop_group_settings.prop_group_id = #{options[:prop_group_id]} and gw_prop_groups.state = 'public'"
      p_joins = "LEFT JOIN gw_prop_groups ON gw_prop_groups.id = gw_prop_group_settings.prop_group_id"
      props = Gw::PropGroupSetting.select("gw_prop_group_settings.prop_other_id").where(p_cond).joins(p_joins)
      return [] if props.blank?
      props.each do |prop|
        cond_group_ids << prop.prop_other_id
      end
      search_prop_ids = Gw.join([cond_group_ids], ',')
      cond_prop_group.concat " and gw_prop_others.id in (#{search_prop_ids})"
    end

    if params[:prop_id].blank?
      if is_gw_admin
        other_items = _mdl.where(cond + cond_prop_group + cond_type + cond_other_admin)
                          .order('type_id, gid, coalesce(sort_no, 0), name')
                          .joins(:prop_other_roles)
                          .group("gw_prop_others.id")
      else
        other_items = _mdl.where(cond_other + cond_prop_group + cond_other_admin)
                          .order('type_id, gid, coalesce(sort_no, 0), name, gw_prop_others.gid')
                          .joins(:prop_other_roles)
                          .group("gw_prop_others.id")
      end

      parent_groups = Gw::PropOther.get_parent_groups

      _items = other_items.sort{|a, b|
          ag = System::GroupHistory.find_by(id: a.get_admin_first_id(parent_groups))
          bg = System::GroupHistory.find_by(id: b.get_admin_first_id(parent_groups))
          flg = (!ag.blank? && !bg.blank?) ? ag.sort_no <=> bg.sort_no : 0
          (a.type_id <=> b.type_id).nonzero? or (flg).nonzero? or a.sort_no <=> b.sort_no
      }
      return _items
    else
      _mdl.where("id = #{params[:prop_id]} and delete_state = 0")
    end
  end

  def self.get_settings(_key, options={})
    key = _key.to_s
    options[:nodefault] = 1 if !%w(ssos).index(key).nil?
    ret = {}

    if options[:nodefault].nil?
      ret.merge! Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")
    end

    ind = Gw::Model::UserProperty.get(key.singularize, options)
    if !ind.blank?
      ind = ind.stringify_keys
    end
    if !ind.blank? && !ind[key].blank?
      if key == 'portals'
        ret = ind[key]
        remove_obsolete_rss(ret)
      else
        ret.merge! ind[key]
      end
    end
    return HashWithIndifferentAccess.new(ret)
  end

  def self.remove_obsolete_rss(hh)
    hh.reject! do |item|
      !item[1]['piece_name'].blank? && item[1]['piece_name'].index('piece/gw-rssreader') == 0 if item.length >= 2
    end
  end
end

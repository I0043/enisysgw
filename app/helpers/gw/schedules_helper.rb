# encoding: utf-8
module Gw::SchedulesHelper

  def show_schedule_edit_icon(d, options={})
    par_a = [%Q(s_date=#{(d).strftime("%Y%m%d")})]
    par_a.push "uid=#{options[:uid]}" if options[:uid].present?
    par_a.push "prop_id=#{options[:prop_id]}" if options[:prop_id].present?
    par_a.push "s_genre=#{options[:s_genre]}" if options[:s_genre].present?
    par_s = Gw.a_to_qs(par_a);
    return %Q(<a href="/gw/schedules/new#{par_s}">#{image_tag('/images/icon/add4.png', alt: "edit")}</a>).html_safe
  end

  def create_month_class(week_add_day, date, holidays, params)
    class_str = %Q(scheduleData #{Gw.weekday_s(week_add_day, :mode => :eh, :no_weekday => 1, :holidays => holidays)})
    class_str.concat ' today' if (week_add_day) == Date.today
    class_str.concat ' selectDay' if (week_add_day) == nz(date, Date.today.to_s).to_date
    return class_str
  end

  def smart_create_month_class(week_add_day, date, holidays, params)
    class_str = %Q(#{Gw.weekday_s(week_add_day, :mode => :eh, :no_weekday => 1, :holidays => holidays)})
    class_str.concat ' today' if (week_add_day) == Date.today
    class_str.concat ' selectDay' if (week_add_day) == nz(date, Date.today.to_s).to_date
    return class_str
  end

  def smart_show_one(i, week_add_day, user_id)
    result = ""
    @schedules.each_with_index do |schedule, j|
      schedule_id = "sche#{schedule.id}_#{i}_#{j}_#{1}"
      if schedule.date_between(week_add_day)
        participant = false
        schedule.schedule_users.each do |schedule_user|
          participant = schedule_user.uid == user_id.to_i
          break if participant
        end

        result += smart_show_week_one(schedule, week_add_day, schedule_id, user_id) if participant
      end
    end
    return result.html_safe
  end

  def smart_show_prop_one(i, week_add_day)
    result = ""
    @schedules.each_with_index do |schedule, j|
      schedule_id = "sche#{schedule.id}_#{i}_#{j}_#{1}"
      if schedule.date_between(week_add_day)
        prop = Gw::ScheduleProp.where(prop_id: @prop.id, schedule_id: schedule.id)
        if prop.present?
          result += smart_show_week_one(schedule, week_add_day, schedule_id, nil)
        end
      end
    end
    return result.html_safe
  end

  def create_month_class_noweek(week_add_day, date, holidays, params)
    class_str = %Q(scheduleData dayHeder #{Gw.weekday_s(week_add_day, :mode => :eh, :no_weekday => 1, :holidays => holidays)})
    class_str.concat ' today' if (week_add_day) == Date.today
    class_str.concat ' selectDay' if (week_add_day) == nz(date, Date.today.to_s).to_date
    return class_str
  end

  def create_schedule_tooltip(schedule, is_ie, options = {})
    is_ie = Gw.ie?(request) unless is_ie
    title_category = Gw.yaml_to_array_for_select('gw_schedules_title_categories').to_a.rassoc(schedule.title_category_id.to_i) # 件名カテゴリ
    is_public = Gw.yaml_to_array_for_select('gw_schedules_public_states').to_a.rassoc(schedule.is_public.to_i) # 公開範囲
    if title_category.present?
      title = t("rumi.schedule.tooltip.title") + "：【#{title_category[0]}】 #{schedule.title}"
    else
      title = t("rumi.schedule.tooltip.title") + "：#{schedule.title}"
    end

    place = schedule.place.blank? ? "" : t("rumi.schedule.tooltip.place") + "： #{schedule.place}"
    memo = schedule.memo.blank? ? "" : is_ie ? t("rumi.schedule.tooltip.memo") + "： #{schedule.memo}" : t("rumi.schedule.tooltip.memo") + "： #{Gw.br(schedule.memo)}"
    inquire_to = schedule.inquire_to.blank? ? "" : t("rumi.schedule.tooltip.inquire_to") + "： #{schedule.inquire_to}"
    public = is_public.blank? ? nil : t("rumi.schedule.tooltip.public") + "： #{is_public[0]}"

    user_names = options.present? && options[:user_names] ? options[:user_names] : schedule.get_usernames
    user_names = user_names.present? ? t("rumi.schedule.tooltip.users") + "： #{user_names}" : ""
    prop_names = options.present? && options[:prop_names] ? options[:prop_names] : schedule.get_propnames
    prop_names = prop_names.present? ? t("rumi.schedule.tooltip.prop") + "： #{prop_names}" : ""

    tooltip_a = [title,
      place,
      memo,
      prop_names.present? ? inquire_to : "",
      public,
      user_names,
      prop_names.present? ? prop_names : ""
    ]
    tooltip = Gw.join(tooltip_a, is_ie ?  "\n" : '<br/>')
    tooltip = Gw.simple_strip_html_tags(tooltip, :exclude_tags=>'br/')
    return tooltip
  end

  def show_week_one(schedule, week_add_day, schedule_id, user_id, prop, options = {})
    return_body = ""
    if schedule.date_between(week_add_day)
      participant = false
      if user_id.present?
        schedule.schedule_users.each do |schedule_user|
          break if participant
          participant = schedule_user.uid == user_id
        end
      else
        schedule.schedule_props.each do |schedule_prop|
          break if participant
          participant = schedule_prop.prop_id == prop.id
        end
      end
      if participant
        if @schedule_settings[:view_schedule_title_display].to_i == 1
          class_str = "schedule-show-ellipsis"
          schedule_show_time = schedule.show_time_ellipsis(week_add_day)
        else
          class_str = "schedule-show-all"
          schedule_show_time = schedule.show_time(week_add_day)
        end

        if schedule.is_public_auth?(@gw_admin)
          if user_id.to_s == Core.user.id.to_s && schedule.remind_unseen?(schedule) && !request.env['PATH_INFO'].include?("schedule_props")
            new = "<p class='new'><img src='/images/icon/ic_new.gif' width='23' height='12' alt='" + t("rumi.state.unread") + "'/></p>"
          else
            new = nil
          end

          dup = nil
          if user_id.present? && (schedule.allday == 2 || schedule.allday.blank?) && @sp_mode == :schedule
            if schedule.allday == 2
              st_at = schedule.st_at.beginning_of_day
              ed_at = schedule.ed_at.end_of_day
            else
              st_at = schedule.st_at
              ed_at = schedule.ed_at
            end
            day_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)

            st_range = Gw::ScheduleUser.where(uid: user_id)
                                       .where(Gw::ScheduleUser.arel_table[:st_at].in(day_range))
                                       .where("st_at != ?", ed_at)
            ed_range = Gw::ScheduleUser.where(uid: user_id)
                                       .where(Gw::ScheduleUser.arel_table[:ed_at].in(day_range))
                                       .where("ed_at != ?", st_at)
            out_range = Gw::ScheduleUser.where(uid: user_id)
                                        .where("st_at <= ?", st_at)
                                        .where("ed_at >= ?", ed_at)
            if st_range.size > 1 || ed_range.size > 1 || out_range.size > 1
              st_schedules = Gw::Schedule.where(id: st_range.map(&:schedule_id), delete_state: 0)
                                         .where("allday = 2 or allday is null and st_at between ? and ?", st_at, ed_at)
              ed_schedules = Gw::Schedule.where(id: ed_range.map(&:schedule_id), delete_state: 0)
                                         .where("allday = 2 or allday is null and ed_at between ? and ?", st_at, ed_at)
              out_schedules = Gw::Schedule.where(id: out_range.map(&:schedule_id), delete_state: 0)
                                          .where("allday = 2 or allday is null")
              if st_schedules.size > 1 || ed_schedules.size > 1 || out_schedules.size > 1
                dup = "<p class='dup'><img src='/images/icon/ic_dup.png' width='23' height='12' alt='重複'/></p>"
              end
            end
          end

          if @schedule_settings[:view_place_display] == '1' &&
              schedule.place.present?
            place = "<span class='place'>（#{schedule.place}）</span>"
          else
            place = nil
          end
          public = (schedule.is_public.to_i == 3 ? "[#{I18n.t("rumi.schedule_list.public.state_3")}]" : "")
html = <<HTML
<div title="#{create_schedule_tooltip(schedule, @ie, options)}" class="ind #{class_str}" id="#{schedule_id}">
  <a class="#{schedule.get_category_class}" href="/gw/schedules/#{schedule.id}/show_one">
    #{new}
    #{dup}
    <span>#{schedule_show_time}</span>
    <span>#{required(public)}#{schedule.title}</span>
    #{place}
  </a>
</div>
HTML
        else
          t = schedule.show_time(week_add_day)
          title = @ie ? "#{t} [#{t("rumi.schedule.private")}]" : "<span>#{t} [#{t("rumi.schedule.private")}]</span>"
html = <<HTML
<div title="#{title}" id="#{schedule_id}" class="ind #{class_str}">
  <a class="category0"><span>#{schedule_show_time}</span>
  <span>[#{t("rumi.schedule.private")}]</span></a>
</div>
HTML
        end
        return_body = html.html_safe
      end
    end
    return return_body
  end

  def smart_show_week_one(schedule, week_add_day, schedule_id, user_id, options = {})
    class_str = "schedule-show-ellipsis"
    schedule_show_time = schedule.show_time_ellipsis(week_add_day)

    if schedule.is_public_auth?(@gw_admin)
      new = user_id.to_s == Core.user.id.to_s && schedule.remind_unseen?(schedule) && !request.env['PATH_INFO'].include?("smart_schedule_props") ?
        "<span class='new'>new</span>" : "<span class='read'></span>"

      dup_flg = false
      if user_id.present? && (schedule.allday == 2 || schedule.allday.blank?)
        if schedule.allday == 2
          time_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)
          st_at = schedule.st_at.beginning_of_day
          ed_at = schedule.ed_at.end_of_day
        else
          time_range = (schedule.st_at..schedule.ed_at)
          st_at = schedule.st_at
          ed_at = schedule.ed_at
        end
        day_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)

        st_range = Gw::ScheduleUser.where(uid: user_id)
                                   .where(Gw::ScheduleUser.arel_table[:st_at].in(day_range))
                                   .where("st_at != ?", ed_at)
        ed_range = Gw::ScheduleUser.where(uid: user_id)
                                   .where(Gw::ScheduleUser.arel_table[:ed_at].in(day_range))
                                   .where("ed_at != ?", st_at)
        out_range = Gw::ScheduleUser.where(uid: user_id)
                                    .where("st_at <= ?", st_at)
                                    .where("ed_at >= ?", ed_at)
        if st_range.size > 1 || ed_range.size > 1 || out_range.size > 1
          st_schedules = Gw::Schedule.where(id: st_range.map(&:schedule_id), delete_state: 0)
                                     .where("allday = 2 or allday is null and st_at between ? and ?", st_at, ed_at)
          ed_schedules = Gw::Schedule.where(id: ed_range.map(&:schedule_id), delete_state: 0)
                                     .where("allday = 2 or allday is null and ed_at between ? and ?", st_at, ed_at)
          out_schedules = Gw::Schedule.where(id: out_range.map(&:schedule_id), delete_state: 0)
                                      .where("allday = 2 or allday is null")
          if st_schedules.size > 1 || ed_schedules.size > 1 || out_schedules.size > 1
            dup_flg = true
          end
        end
      end
      dup = dup_flg ? "<span class='dup'>dup</span>" :  "<span class='single'></span>"

      place = @schedule_settings[:view_place_display] == '1' && schedule.place.present? ?
        "<span class='place'>（#{schedule.place}）</span>" : nil


html = <<HTML
<div title="" class="ind #{class_str}" id="#{schedule_id}" style="background-color: #FFF;">
  <a class="#{schedule.get_category_class}" href="/gw/smart_schedules/#{schedule.id}/show_one" style="margin-bottom:10px;">
    #{new}
    #{dup}
    <span class="times">#{schedule_show_time}</span>
    <span class='title'>#{truncate(schedule.title, :length => 15)}</span>
    #{place}
  </a>
</div>
HTML
    else
      t = schedule.show_time(week_add_day)
      title = "<span>#{t} [#{t("rumi.schedule.private")}]</span>"
      title = "#{t} [#{t("rumi.schedule.private")}]" if @ie
html = <<HTML
<div title="#{title}" id="#{schedule_id}" class="ind #{class_str}" style="background-color: #FFF;">
  <a class="category0"><span>#{schedule_show_time}</span>
  <span class="title">[#{t("rumi.schedule.private")}]</span></a>
</div>
HTML
    end
    html.html_safe
  end

  def smart_show_day_one(schedule, schedule_data, participant_schedule_cnt, public, schedule_id, user_id, options = {})
    html = ""
    if nz(schedule.allday, 0).to_i > 0
      head = participant_schedule_cnt == 0 ? "<div class='' id=''>" : nil

      if public
        new = user_id.to_s == Core.user.id.to_s && schedule.remind_unseen?(schedule) ?
          "<span class='new'>new</span>" : "<span class='read'></span>"
        dup_flg = false
        if user_id.present? && (schedule.allday == 2 || schedule.allday.blank?)
          if schedule.allday == 2
            time_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)
            st_at = schedule.st_at.beginning_of_day
            ed_at = schedule.ed_at.end_of_day
          else
            time_range = (schedule.st_at..schedule.ed_at)
            st_at = schedule.st_at
            ed_at = schedule.ed_at
          end
          day_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)

          st_range = Gw::ScheduleUser.where(uid: user_id)
                                     .where(Gw::ScheduleUser.arel_table[:st_at].in(day_range))
                                     .where("st_at != ?", ed_at)
          ed_range = Gw::ScheduleUser.where(uid: user_id)
                                     .where(Gw::ScheduleUser.arel_table[:ed_at].in(day_range))
                                     .where("ed_at != ?", st_at)
          out_range = Gw::ScheduleUser.where(uid: user_id)
                                      .where("st_at <= ?", st_at)
                                      .where("ed_at >= ?", ed_at)
          if st_range.size > 1 || ed_range.size > 1 || out_range.size > 1
            st_schedules = Gw::Schedule.where(id: st_range.map(&:schedule_id), delete_state: 0)
                                       .where("allday = 2 or allday is null and st_at between ? and ?", st_at, ed_at)
            ed_schedules = Gw::Schedule.where(id: ed_range.map(&:schedule_id), delete_state: 0)
                                       .where("allday = 2 or allday is null and ed_at between ? and ?", st_at, ed_at)
            out_schedules = Gw::Schedule.where(id: out_range.map(&:schedule_id), delete_state: 0)
                                        .where("allday = 2 or allday is null")
            if st_schedules.size > 1 || ed_schedules.size > 1 || out_schedules.size > 1
              dup_flg = true
            end
          end
        end
        dup = dup_flg ? "<span class='dup'>dup</span>" : "<span class='single'></span>"

        body = <<END
<a class="#{schedule.get_category_class}" href="/gw/smart_schedules/#{schedule.id}/show_one" style="margin-bottom:10px;">
#{new}
#{dup}
<span class="times">#{schedule.show_time_ellipsis(@st_date)}</span>
<span class="title">#{truncate(schedule.title, :length => 15)}</span> </a>
END
      else
        body = <<END
<span class="times">#{schedule.show_time(@st_date)}</span>
<span class="title">[#{t("rumi.schedule.private")}]</span>
END
      end

      foot = nil
      foot = "</div>" if participant_schedule_cnt ==  schedule_data[:allday_cnt]
html = <<HTML
#{head}
<div class="ind" id="#{schedule_id}">
#{body}
</div>
#{foot}
HTML
    else
      head = "<div class='ind' id='#{schedule_id}'>"
      if public
        new = user_id.to_s == Core.user.id.to_s && schedule.remind_unseen?(schedule) ?
          "<span class='new'>new</span>" : "<span class='read'></span>"
        dup_flg = false
        if user_id.present? && (schedule.allday == 2 || schedule.allday.blank?)
          if schedule.allday == 2
            time_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)
            st_at = schedule.st_at.beginning_of_day
            ed_at = schedule.ed_at.end_of_day
          else
            time_range = (schedule.st_at..schedule.ed_at)
            st_at = schedule.st_at
            ed_at = schedule.ed_at
          end
          day_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)

          st_range = Gw::ScheduleUser.where(uid: user_id)
                                     .where(Gw::ScheduleUser.arel_table[:st_at].in(day_range))
                                     .where("st_at != ?", ed_at)
          ed_range = Gw::ScheduleUser.where(uid: user_id)
                                     .where(Gw::ScheduleUser.arel_table[:ed_at].in(day_range))
                                     .where("ed_at != ?", st_at)
          out_range = Gw::ScheduleUser.where(uid: user_id)
                                      .where("st_at <= ?", st_at)
                                      .where("ed_at >= ?", ed_at)
          if st_range.size > 1 || ed_range.size > 1 || out_range.size > 1
            st_schedules = Gw::Schedule.where(id: st_range.map(&:schedule_id), delete_state: 0)
                                       .where("allday = 2 or allday is null and st_at between ? and ?", st_at, ed_at)
            ed_schedules = Gw::Schedule.where(id: ed_range.map(&:schedule_id), delete_state: 0)
                                       .where("allday = 2 or allday is null and ed_at between ? and ?", st_at, ed_at)
            out_schedules = Gw::Schedule.where(id: out_range.map(&:schedule_id), delete_state: 0)
                                        .where("allday = 2 or allday is null")
            if st_schedules.size > 1 || ed_schedules.size > 1 || out_schedules.size > 1
              dup_flg = true
            end
          end
        end
        dup = dup_flg ? "<span class='dup'>dup</span>" : "<span class='single'></span>"

        body = <<END
<a class="#{schedule.get_category_class}" href="/gw/smart_schedules/#{schedule.id}/show_one" style="margin-bottom:10px;">
#{new}
#{dup}
<span class="times">#{schedule.show_time_ellipsis(@st_date)}</span>
<span class="title">#{truncate(schedule.title, :length => 15)}</span> </a>
END
      else
        body = <<END
<span class="times">#{schedule.show_time(@st_date)}</span>
<span class="title">[#{t("rumi.schedule.private")}]</span>
END
      end
      foot = "</div>"

html = <<HTML
#{head}
#{body}
#{foot}
HTML
    end
    html.html_safe
  end

  def show_day_new(schedule, user_id)
    new = ""
    if user_id.to_s == Core.user.id.to_s && schedule.remind_unseen?(schedule)
      new = "<p class='new'>#{image_tag '/images/icon/ic_new.gif', alt: t('rumi.state.unread'), size: '23x12'}</p>"
    end
    new
  end

  def show_day_dup(schedule, week_add_day, schedule_id, user_id, options = {})
    dup = ""
    if user_id.present? && (schedule.allday == 2 || schedule.allday.blank?)
      if schedule.allday == 2
        time_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)
        st_at = schedule.st_at.beginning_of_day
        ed_at = schedule.ed_at.end_of_day
      else
        time_range = (schedule.st_at..schedule.ed_at)
        st_at = schedule.st_at
        ed_at = schedule.ed_at
      end
      day_range = (schedule.st_at.beginning_of_day..schedule.ed_at.end_of_day)

      st_range = Gw::ScheduleUser.where(uid: user_id)
                                 .where(Gw::ScheduleUser.arel_table[:st_at].in(day_range))
                                 .where("st_at != ?", ed_at)
      ed_range = Gw::ScheduleUser.where(uid: user_id)
                                 .where(Gw::ScheduleUser.arel_table[:ed_at].in(day_range))
                                 .where("ed_at != ?", st_at)
      out_range = Gw::ScheduleUser.where(uid: user_id)
                                  .where("st_at <= ?", st_at)
                                  .where("ed_at >= ?", ed_at)
      if st_range.size > 1 || ed_range.size > 1 || out_range.size > 1
        st_schedules = Gw::Schedule.where(id: st_range.map(&:schedule_id), delete_state: 0)
                                   .where("allday = 2 or allday is null and st_at between ? and ?", st_at, ed_at)
        ed_schedules = Gw::Schedule.where(id: ed_range.map(&:schedule_id), delete_state: 0)
                                   .where("allday = 2 or allday is null and ed_at between ? and ?", st_at, ed_at)
        out_schedules = Gw::Schedule.where(id: out_range.map(&:schedule_id), delete_state: 0)
                                    .where("allday = 2 or allday is null")
        if st_schedules.size > 1 || ed_schedules.size > 1 || out_schedules.size > 1
          dup = "<p class='dup'><img src='/images/icon/ic_dup.png' width='23' height='12' alt='重複'/></p>"
        end
      end
    end
    dup
  end

  def show_one_title(schedule, schedule_id, user_id)
    title = ""
    title += show_day_new(schedule, user_id) + "\n"
    title += show_day_dup(schedule, @calendar_first_day, schedule_id, user_id) + "\n"
    title += "<p class='time'>#{schedule.show_time(@st_date)}</p>\n"
    public = (schedule.is_public.to_i == 3 ? required("[#{I18n.t("rumi.schedule_list.public.state_3")}]") : "")
    title += "<p class='titles'>#{public}#{schedule.title}</p>\n"
    return title.html_safe
  end

  def get_hrefs(params, d)
    td_s = !params[:s_date].blank? ? params[:s_date] : d.strftime("%Y%m%d")
    link_uid = Core.user.id

    value = case @sp_mode
    when :schedule, :list
      {user: {
        day: gw_schedule_path(td_s, uid: link_uid),
        week: gw_schedules_path(s_date: td_s, uid: link_uid),
        month: show_month_gw_schedules_path(s_date: td_s, uid: link_uid),
        list: gw_schedule_lists_path(s_year: d.year, s_month: d.month)
      }}
    end
    return value
  end

  def get_calendar_options(tag_name)
    return {
      hidden: 1, id: Gw.idize(tag_name), time: false,
      clear_button: false,
      onchange: "calendar_schedule_redirect($F(this));",
      image: '/images/icon/calendar.png',
    }
  end

  def get_schedule_move_ab(d)
    @schedule_move_ab = if @sp_mode == :event
      [
        [@st_date.months_ago(1), t("rumi.schedule.line_box.last_month")],
        [@st_date - 7, t("rumi.schedule.line_box.last_week")],
        [Date.today, t("rumi.schedule.line_box.today")],
        [@st_date + 7, t("rumi.schedule.line_box.next_week")],
        [@st_date.months_since(1), t("rumi.schedule.line_box.next_month")]
      ]
    else
      [
        [d.months_ago(1), t("rumi.schedule.line_box.last_month")],
        [d-7, t("rumi.schedule.line_box.last_week")],
        [d-1, image_tag('/images/icon/arrow_l.png', :alt => '', :size => '15x30')],
        [Date.today, t("rumi.schedule.line_box.today")],
        [d+1, image_tag('/images/icon/arrow_r.png', :alt => '', :size => '15x30')],
        [d+7, t("rumi.schedule.line_box.next_week")],
        [d.months_since(1), t("rumi.schedule.line_box.next_month")]
      ]
    end
  end

  def get_schedule_move_ab_m(d)
    @schedule_move_ab = if @sp_mode == :event
      [
        [Date::new(@st_date.year - 1, @st_date.month, 1), t("rumi.schedule.line_box.last_year")],
        [@st_date.month == 1 ? Date::new(@st_date.year - 1, 12, 1) : Date::new(@st_date.year, @st_date.month - 1, 1), t("rumi.schedule.line_box.last_month")],
        [Date.today, t("rumi.schedule.line_box.now_month")],
        [@st_date.month == 12 ? Date::new(@st_date.year + 1, 1, 1) : Date::new(@st_date.year, @st_date.month + 1, 1), t("rumi.schedule.line_box.next_month")],
        [Date::new(@st_date.year + 1, @st_date.month, 1), t("rumi.schedule.line_box.next_year")]
      ]
    else
      [
        [Date::new(d.year - 1, d.month, 1), t("rumi.schedule.line_box.last_year")],
        [d.month == 1 ? Date::new(d.year - 1, 12, 1) : Date::new(d.year, d.month - 1, 1), t("rumi.schedule.line_box.last_month")],
        [Date.today, t("rumi.schedule.line_box.now_month")],
        [d.month == 12 ? Date::new(d.year + 1, 1, 1) : Date::new(d.year, d.month + 1, 1), t("rumi.schedule.line_box.next_month")],
        [Date::new(d.year + 1, d.month, 1), t("rumi.schedule.line_box.next_year")]
      ]
    end
  end

  def schedule_new_link(d, options={})
    par_a = [%Q(s_date=#{(d).strftime("%Y%m%d")})]
    par_a.push "uid=#{options[:uid]}" if options[:uid].present?
    par_a.push "prop_id=#{options[:prop_id]}" if options[:prop_id].present?
    par_a.push "s_genre=#{options[:s_genre]}" if options[:s_genre].present?
    par_s = Gw.a_to_qs(par_a);
    return %Q(/gw/schedules/new#{par_s}).html_safe
  end

  def day_link(week_add_day, mode)
    link = ""
    if @sp_mode == :schedule
      link = %Q(/gw/schedules/#{(week_add_day).strftime('%Y%m%d')}#{@link_params})
    else
      if mode == "month"
        link = %Q(/gw/schedule_props/#{(week_add_day).strftime('%Y%m%d')}?s_genre=#{@genre}&cls=#{@cls}#{params[:prop_id]})
      else
        link = %Q(/gw/schedule_props/#{(week_add_day).strftime('%Y%m%d')}?s_genre=#{@genre}&cls=#{@cls}&prop_id=#{params[:prop_id]}&type_id=#{params[:type_id]}&s_other_admin_gid=#{params[:s_other_admin_gid]})
      end
    end

    return link
  end

  def schedule_edit_auth(week_add_day)
    flg = false

    if @sp_mode == :schedule
      if @edit && @user.present? && @user.schedule_auth?
        flg = true
      end
    elsif @sp_mode == :prop
      if @prop.delete_state == 1
        flg = false
      elsif @gw_admin
        flg = true
      elsif Gw::PropOtherRole.is_admin?(@prop.id)
        flg = true
      else
        _edit = Gw::PropOtherRole.is_edit?(@prop.id)
        d_load_st_flg = @prop.d_load_st.present? ? @prop.d_load_st <= week_add_day.to_time.beginning_of_day : true
        d_load_ed_flg = @prop.d_load_ed.present? ? @prop.d_load_ed >= week_add_day.to_time.end_of_day : true
        reserved_state_flg = @prop.reserved_state == 1 ? true : false
        flg = _edit && d_load_st_flg && d_load_ed_flg && reserved_state_flg && @prop.available?(week_add_day) 
      end
    end

    return flg
  end

  def get_d_load(s_date)
    dd = Gw.date8_to_date(params[:s_date], :default=>'')

    now = Time.now
    hour = now.hour # 時間
    min = 0

    _wrk_st = dd.present? ? Gw.date_to_time(dd) : Time.local(now.year, now.month, now.day, hour, min, 0)
    return (I18n.l _wrk_st), (I18n.l (_wrk_st + 60*60))
  end

  def get_tab_box_radio(f, params)
    tab_box_id = params[:init].present? ? params[:init][:repeat_mode].to_i : 1
    form_kind_radio = radio(f, 'tab_box_id', Gw.yaml_to_array_for_select('gw_schedules_tab_box_ids'),
      :selected=> nz(tab_box_id, 1).to_i, :force_tag=>1, :return_array=>1, :onclick=>'switchRepeat("onchange");')
    return Gw.join(form_kind_radio, "")
  end

  def get_form_kind_radio(f, params)
    form_kind_id = params[:item].present? ? params[:item][:form_kind_id].to_i : 0
    form_kind_radio = radio(f, 'form_kind_id', Gw.yaml_to_array_for_select('gw_schedules_form_kind_ids'),
      :selected=> nz(form_kind_id, 0).to_i, :force_tag=>1, :return_array=>1, :onclick=>'form_kind_id_switch("onchange");')
    return Gw.join(form_kind_radio, "")
  end

  def get_hidden_field(action)
    case action
    when 'edit'
      created_at   = @item.created_at
      creator_uid  = @item.creator_uid
      creator_uname = @item.creator_uname
      creator_ucode = @item.creator_ucode
      creator_gid  = @item.creator_gid
    when 'quote'
      creator_uid = Core.user.id
      creator_uname = Core.user.name
      creator_ucode = Core.user.code
      creator_gid = Core.user_group.id
      created_at = 'now()'
    when 'create', 'update'
      creator_uid = params[:item][:creator_uid]
      creator_uname = params[:item][:creator_uname]
      creator_ucode = params[:item][:creator_ucode]
      creator_gid = params[:item][:creator_gid]
      created_at = params[:item][:created_at]
    else
      creator_uid = Core.user.id
      creator_uname = Core.user.name
      creator_ucode = Core.user.code
      creator_gid = Core.user_group.id
      created_at = 'now()'
    end

    tag = ""
    tag = hidden_field_tag('item[creator_uid]', "#{creator_uid}")
    tag += hidden_field_tag('item[creator_uname]', "#{creator_uname}")
    tag += hidden_field_tag('item[creator_ucode]', "#{creator_ucode}")
    tag += hidden_field_tag('item[creator_gid]', "#{creator_gid}")
    tag += hidden_field_tag('item[created_at]', "#{created_at}")
    tag += hidden_field_tag('init[action]', "#{action}")
    return raw tag
  end

  def get_hidden_field_prop(params)
    ucls = ''
    prop_id = ''
    prop_name = ''
    prop_gname = ''
    prop_gid = ''
    prop_gcode = ''

    if params[:prop_id].present? && params[:s_genre].present?
      genre = params[:s_genre]
      prop = Gw::PropOther.find_by_id(params[:prop_id])
      if prop.delete_state == 0 && prop.reserved_state == 1
        ucls = genre
        prop_id = params[:prop_id]
        prop_name = prop.name
        prop_gname = !prop.gname.blank? ? prop.gname : ""
        prop_gid = !prop.gid.blank? ? prop.gid : Core.user_group.id
        group = System::Group.find(prop_gid)
        prop_gcode = group.code
      end
    end

    tag = ""
    tag += hidden_field_tag('init[prop_cls]', ucls)
    tag += hidden_field_tag('init[prop_id]', prop_id)
    tag += hidden_field_tag('init[prop_name]', prop_name)
    tag += hidden_field_tag('init[prop_gname]', prop_gname)
    tag += hidden_field_tag('init[prop_gcode]', prop_gcode)
    return raw tag
  end

  def repeat_radio_s(f, repeat_mode, params)
    html = ""

    repeat_class_id = params[:item].present? ? params[:item][:repeat_class_id].to_i : 0
    repeat_class_id = @item.repeat.class_id if (params[:action] == 'edit' || params[:action] == 'quote') && repeat_mode != 1

    weekday_selected_s = Gw.checkbox_to_string(params[:item].blank? ? '' : params[:item][:repeat_weekday_ids])

    repeat_radio_a = radio(f, 'repeat_class_id', Gw.yaml_to_array_for_select('gw_schedules_repeats'), :selected=> nz(repeat_class_id, 0).to_i, :force_tag=>1, :return_array=>1, :onclick=>'switchRepeatClass();')
    repeat_radio_a_w = []
    repeat_weekday_ids = check_boxes(f, 'repeat_weekday_ids', Gw.yaml_to_array_for_select('gw_schedules_repeat_weekday_ids'),
      :selected_str => weekday_selected_s)
    repeat_weekday_ids = %Q(<table id="repeat_weekday_ids_table"><tr><td><p>#{t("rumi.schedule.message.repeat_select")}</p>#{repeat_weekday_ids}</td></tr></table>)
    repeat_radio_a.each_with_index{|x, i| repeat_radio_a_w.push %Q(<tr>#{i != 0 ? '' : %Q(<th rowspan="#{repeat_radio_a.length}">#{t("rumi.schedule.message.rule")}#{required}</th>)}<td>#{x}#{i != 2 ? '' : repeat_weekday_ids}</td></tr>)}

    html = repeat_radio_a_w.join
    return html
  end

  def get_owner_u(params)
    owner_u = {}
    if params[:item].present? && params[:item][:owner_uid].present?
      owner_u = {:id=>params[:item][:owner_uid], :displayname=>params[:item][:owner_udisplayname]}
    elsif !@item.owner_uid.blank?  and params[:action] != 'quote'
      owner_user = Gw::Model::Schedule.get_user(@item.owner_uid)
      if owner_user.blank?
        if @item.schedule_prop.blank? || @item.schedule_prop.is_kanzai? >= 3
          owner_u = {:id=>Core.user.id, :displayname=>Core.user.display_name}
        else
          owner_u = {:id=>'', :displayname=>''}
        end
      else
        owner_u = {:id=>@item.owner_uid, :displayname=>owner_user.display_name}
      end
    else
      owner_u = {:id=>Core.user.id, :displayname=>Core.user.display_name}
    end
    return owner_u
  end

  def defalut_props(params)
    _params = params.dup

    _defalut_props = Gw::ScheduleProp.getajax _params
    return _defalut_props.collect{|x| [x[2], x[1]]}
  end

  def get_prop_schedules
    prop_schedules = Hash::new

    @props.each do |prop|
      key = "prop_#{prop.id}"
      prop_schedules[key] = Hash::new
      prop_schedules[key][:schedules] = Array.new
      prop_schedules[key][:allday_flg] = false
      prop_schedules[key][:allday_cnt] = 0

      @schedules.each do |schedule|
        participant = false
        schedule.schedule_props.each do |schedule_prop|
          break if participant
          participant = schedule_prop.prop_id == prop.id
        end
        if participant
          prop_schedules[key][:schedules] << schedule
          if schedule.allday == 1 || schedule.allday == 2
            prop_schedules[key][:allday_flg] = true
            prop_schedules[key][:allday_cnt] += 1
          end
        end
      end

      prop_schedules[key][:schedule_len] = prop_schedules[key][:schedules].length

      if prop_schedules[key][:schedule_len] == 0
        prop_schedules[key][:trc] = "scheduleTableBody"
        prop_schedules[key][:row] = 1
      else
        if prop_schedules[key][:allday_flg] == true
          prop_schedules[key][:trc] = "alldayLine"
          prop_schedules[key][:row] = (prop_schedules[key][:schedule_len] * 2) - ((prop_schedules[key][:allday_cnt] * 2) - 1)
        else
          prop_schedules[key][:trc] = "scheduleTableBody categoryBorder"
          prop_schedules[key][:row] = prop_schedules[key][:schedule_len] * 2
        end
      end
    end
    return prop_schedules
  end

  def get_schedule_prop_edit(prop)
    is_prop_edit = false

    if prop.delete_state == 1
      is_prop_edit = false
    elsif @gw_admin
      is_prop_edit = true
    elsif Gw::PropOtherRole.is_admin?(prop.id)
      is_prop_edit = true
    else
      _edit = Gw::PropOtherRole.is_edit?(prop.id)
      d_load_st_flg = prop.d_load_st.present? ? prop.d_load_st <= @calendar_first_day.to_time.beginning_of_day : true
      d_load_ed_flg = prop.d_load_ed.present? ? prop.d_load_ed >= @calendar_first_day.to_time.end_of_day : true
      reserved_state_flg = prop.reserved_state == 1 ? true : false
      is_prop_edit = _edit && d_load_st_flg && d_load_ed_flg && reserved_state_flg && prop.available?(@calendar_first_day)
    end
    return is_prop_edit
  end

  def get_user(group_id, params)
    user_id = @item.target_uid.present? ? @item.target_uid : Core.user.id

    users = System::UsersGroup.affiliated_users_to_select_option(
              group_id, System::UsersGroup::TO_SELECT_OPTION_SETTINGS[:system_role])

    user_values = params[:item] && params[:item][:user_json] ? params[:item][:user_json] : nz(@user_json)

    return user_id, users, user_values
  end

  def get_group(params)
    group_id = @item.target_uid.present? ? System::UsersGroup.find_by_user_id(@item.target_uid).group_id : Core.user_group.id

    parent_group_id = Core.user_group.parent_id
    group_child_groups = build_select_parent_groups(System::Group.child_groups_to_select_option(parent_group_id))

    group_values = params[:item] && params[:item][:group_json] ? params[:item][:group_json] : nz(@group_json)

    return group_id, parent_group_id, group_child_groups, group_values
  end

  def get_affiliated
    affiliated_group_id = Core.user_group.id
    user_child_group = build_select_users(System::UsersGroup.affiliated_users_to_select_option(affiliated_group_id))

    return affiliated_group_id, user_child_group
  end

  def get_quote_flg
    quote_flg = false
    is_pref_admin_users = @item.is_schedule_pref_admin_users?
    if is_pref_admin_users && @is_pref_admin
      quote_flg = true
    elsif is_pref_admin_users && !@is_pref_admin
      quote_flg = false
    elsif !is_pref_admin_users
      quote_flg = true
    else
      quote_flg = true
    end
    return quote_flg
  end
  
  def get_maeesages
    message = ""
    if @item.schedule_props.length > 1
      message = "※" + t("rumi.schedule.message.multiple.prop")
      if @schedule_edit_flg && @prop_edit && @auth_level[:edit_level] == 1
        message += t("rumi.schedule.message.multiple.prop_edit")
      end
    end
    if @item.schedule_users.length > 1
      message += "<br />※" + t("rumi.schedule.message.multiple.user")
    end
    return message
  end
end

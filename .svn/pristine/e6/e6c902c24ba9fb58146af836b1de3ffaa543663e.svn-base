# encoding: utf-8
class Gw::Admin::ScheduleSettingsController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.config_settings.scheduler.scheduler.name")
    @piece_head_title = t("rumi.config_settings.scheduler.scheduler.name")
    @side = "setting"
  end

  def admin_deletes
    return http_error(403) unless @gw_admin

    key = 'schedules'
    options = {}
    options[:class_id] = 3
    @item = Gw::Model::Schedule.get_settings key, options
    Page.title = t("rumi.item_delete.schedule.name")
    @piece_head_title = t("rumi.item_delete.schedule.name")
  end

  def edit_admin_deletes
    return http_error(403) unless @gw_admin

    Page.title = t("rumi.item_delete.schedule.name")
    @piece_head_title = t("rumi.item_delete.schedule.name")
    key = 'schedules'
    options = {}
    options[:class_id] = 3

    _params = params[:item]
    hu = nz(Gw::Model::UserProperty.get(key.singularize, options), {})
    default = Gw::NameValue.get_cache('yaml', nil, "gw_#{key}_settings_system_default")

    hu[key] = {} if hu[key].nil?
    hu_update = hu[key]
    hu_update['schedules_admin_delete']     = _params['schedules_admin_delete']
    hu_update['month_view_leftest_weekday'] = '1'
    hu_update['view_place_display']         = '0'

    ret = Gw::Model::UserProperty.save(key.singularize, hu, options)
    if ret == true
       redirect_to gw_config_settings_path, notice: t("rumi.message.notice.delete_setting")
    else
      respond_to do |format|
        format.html {
          hu_update['errors'] = ret
          hu_update.merge!(default){|k, self_val, other_val| self_val}
          @item = hu[key]
          render :action => "admin_deletes"
        }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def export
    uid = Site.user.id
    gid = Site.user.user_groups[0].id
    sche = Gw::Schedule
    cond = "((gw_schedule_users.class_id = 1 and gw_schedule_users.uid = #{uid}) or (gw_schedule_users.class_id = 2 and gw_schedule_users.uid = #{gid}))" +
        " and gw_schedules.delete_state = 0"
    @items = sche.order('gw_schedules.allday DESC, gw_schedule_users.st_at, gw_schedule_users.ed_at, gw_schedules.id').joins(:schedule_users).where(cond)
    parent_items = []
    schedule_parent_ids = []
    @items.each { |item|
      if item.is_public_auth?(@gw_admin)
        if item.schedule_parent_id.blank?
          parent_items << item
        else
          if schedule_parent_ids.blank? || schedule_parent_ids.index(item.schedule_parent_id).blank?
            schedule_parent_ids << item.schedule_parent_id
            parent_items << item
          end
        end
      end
    }
    @items = parent_items
    ical = Gw::Controller::Schedule.convert_ical( @items )
    filename = "schedules.ics"
    send_data(ical, :type => 'text/csv', :filename => filename)
  end

  def import
    Page.title = t("rumi.schedule.import.name")
    @piece_head_title = t("rumi.schedule.import.name")
  end

  def import_file
    Page.title = t("rumi.schedule.import.name")
    @piece_head_title = t("rumi.schedule.import.name")
    par_item = params[:item]

    if par_item.nil? || par_item[:file].nil?
      flash.now[:notice] = t("rumi.schedule.import.message.file") + '<br />'
      respond_to do |format|
        format.html { render :action => "import" }
      end
      return
    end

    filename =  par_item[:file].original_filename
    extname = File.extname(filename)

    tempfile = par_item[:file].open

    success = 0
    error = 0
    error_msg = ''

    if par_item[:file_type] == 'ical'

      if extname != '.ics'
        flash.now[:notice] = t("rumi.schedule.import.message.ical.not_extname") + '<br />'
        respond_to do |format|
          format.html { render :action => "import" }
        end
        return
      end

      case par_item[:nkf]
        when 'sjis'
          file_data =  NKF::nkf('-w -S',tempfile.read)
        else
          file_data =  NKF::nkf('-w',tempfile.read)
      end
      require 'ri_cal'
      categories = Gw::NameValue.get_cache('yaml', nil, "gw_schedules_title_categories")
      begin
        cals = RiCal.parse_string( file_data )
      rescue Exception => e
        flash.now[:notice] = t("rumi.schedule.import.message.ical.not_read") + "（#{e.message}）"
        return render :action => "import"
      end
      cal = cals.first
      unless cal
        flash.now[:notice] = t("rumi.schedule.import.message.ical.not_calendar")
        return render :action => "import"
      end
      wary = ['SU','MO','TU','WE','TH','FR','SA']
      cal.events.map do |event|
        if event.recurrence_id_property.blank?
          if match_scheudle_id = event.uid.match(/^schedule_(\d+)@.*$/)
            schedule_id = match_scheudle_id[1]
            schedule_item = Gw::Schedule.where(id: schedule_id, delete_state: 0).first
            #同一スケジュールIDの参加者に含まれていたら、取り込まない
            if schedule_item.present? && schedule_item.schedule_users.map(&:uid).include?(Site.user.id)
              error_msg += t("rumi.schedule.import.message.ical.overlap") + '<br />'
              error += 1
              next
            end
          end
        end
        if event.dtstart_property.tzid == 'UTC' && event.dtstart.class == Class::DateTime
          dtstart = event.dtstart.new_offset(Rational(+9,24))
          dtend = event.dtend.new_offset(Rational(+9,24))
        else
          dtstart = event.dtstart
          dtend = event.dtend
        end
        _params = Hash::new
        _params[:item] = Hash::new
        _params[:init] = Hash::new
        _params[:item][:title] = ( event.summary.blank? ? t("rumi.schedule.import.value.no_title") : "#{event.summary}" )
        _params[:item][:memo]  = "#{event.description}"
        _params[:item][:place] = "#{event.location}"
        _params[:item][:schedule_props_json] = "[]"
        _params[:item][:schedule_users_json] = "[[\"1\", \"#{Site.user.id}\", \"#{Site.user.name}\"]]"
        _params[:item][:public_groups_json] = '["", "", ""]'
        _params[:item][:owner_uid] = "#{Site.user.id}"
        _params[:item][:creator_uid] = "#{Site.user.id}"
        _params[:item][:creator_gid] = "#{Site.user_group.id}"
        _params[:item][:is_public] = "3"
        _params[:item][:st_at] = "#{dtstart.strftime('%Y-%m-%d %H:%M')}"
        event.categories_property.map{|category|
          _params[:item][:title_category_id] = categories.index(category.to_s.gsub(':',''))
        }
        if dtstart.class == Class::Date || ( dtstart == dtend - 1 && dtstart.hour == 0 && dtstart.min == 0)
          _params[:item][:allday_radio_id] = ["2"]
          _params[:item][:repeat_allday_radio_id] = ["2"]
          _params[:item][:st_at] = DateTime.new(dtstart.year, dtstart.month, dtstart.day, 0, 0).strftime('%Y-%m-%d %H:%M')
          _dtend = dtend - 1
          _params[:item][:ed_at] = DateTime.new(_dtend.year, _dtend.month, _dtend.day, 23, 59).strftime('%Y-%m-%d %H:%M')
        else
          _params[:item][:ed_at] = "#{dtend.strftime('%Y-%m-%d %H:%M')}"
        end
        if !event.rrule_property.blank?
          _params[:init][:repeat_mode] = "2"
          continue_flag = 0
          event.rrule_property.map{|rule|
            if rule.until.blank?
              continue_flag = 1
              error_msg += t("rumi.schedule.import.message.no_end_at_repeat") + '<br />'
              next
            end
            if rule.until.tzid == 'UTC'
              until_dt = DateTime.new(rule.until.year, rule.until.month, rule.until.day, rule.until.hour, rule.until.min, 0, Rational(0,24)).new_offset(Rational(+9,24))
            else
              until_dt = DateTime.new(rule.until.year, rule.until.month, rule.until.day, rule.until.hour, rule.until.min, 0, Rational(+9,24))
            end
            _params[:item][:repeat_st_date_at] = "#{dtstart.strftime('%Y-%m-%d')}"
            _params[:item][:repeat_ed_date_at] = "#{until_dt.strftime('%Y-%m-%d')}"
            if dtstart.class == Class::Date || ( dtstart == dtend - 1 && dtstart.hour == 0 && dtstart.min == 0)
              _params[:item][:repeat_st_time_at] = "00:00"
              _params[:item][:repeat_ed_time_at] = "23:59"
            else
              _params[:item][:repeat_st_time_at] = "#{dtstart.strftime('%H:%M')}"
              _params[:item][:repeat_ed_time_at] = "#{dtend.strftime('%H:%M')}"
            end
           if !rule.interval.blank? && rule.interval.to_i > 1
              continue_flag = 1
              error_msg += t("rumi.schedule.import.message.blank_repeat") + '<br />'
           end
           case rule.freq
             when 'DAILY'
              _params[:item][:repeat_class_id] = '1'
             when 'WEEKLY'
              _params[:item][:repeat_class_id] = '3'
              _params[:item][:repeat_weekday_ids] = {}
              weekday_ids = ''
              rule.by_list[:byday].each{|w|
                w = w.to_s
                weekday_ids += ( weekday_ids.blank? ? wary.index(w).to_s : ':'+wary.index(w).to_s ) #:でつなぐ
              }
              _params[:item][:repeat_weekday_ids] = weekday_ids
            else
              error_msg += t("rumi.schedule.import.message.fail_repeat") + '<br />'
              continue_flag = 1
           end
          }
          item = Gw::Schedule.new()
          if continue_flag == 0 && Gw::ScheduleRepeat.save_with_rels_concerning_repeat(item, _params, :create)
            # 新着情報(新規作成時)を作成
            item.build_created_remind
            success += 1
          else
            error_msg += item.errors.full_messages.join("<br />\n")
            error += 1
          end
        elsif !event.recurrence_id_property.blank?

        else
          _params[:init][:repeat_mode] = "1"
          item = Gw::Schedule.new()
          if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(item, _params, :create)
            # 新着情報(新規作成時)を作成
            item.build_created_remind
            success += 1
          else
            error_msg += item.errors.full_messages.join("<br />\n")
            error += 1
          end
        end
      end
    elsif par_item[:file_type] == 'csv'

      if extname != '.csv'
        flash.now[:notice] = t("rumi.schedule.import.message.csv.not_extname") + '<br />'
        respond_to do |format|
          format.html { render :action => "import" }
        end
        return
      end

      require 'csv'
      return if params[:item].nil?
      par_item = params[:item]

      file_data =  NKF::nkf('-w -Lu',tempfile.read)
      if file_data.blank?
      else
        csv = CSV.parse(file_data)

        csv_result = Array.new
        csv.each_with_index do |row, i|
          _csv = row.dup
          _params = Hash::new
          _params[:item] = Hash::new
          _params[:init] = Hash::new
          if i == 0
            _csv << 'error'
            csv_result << _csv
          elsif row.empty?
          else
            if row.length == 11
              _params[:item][:title] = "#{row[0]}"
              _params[:item][:st_at] = "#{row[1]} #{row[2]}"
              _params[:item][:ed_at] = "#{row[3]} #{row[4]}"
              _params[:item][:memo]  = "#{row[6]}"
              _params[:item][:place] = "#{row[7]}"
              _params[:item][:schedule_props_json] = "[]"
              _params[:item][:schedule_users_json] = "[[\"1\", \"#{Site.user.id}\", \"#{Site.user.name}\"]]"
              _params[:item][:public_groups_json] = '["", "", ""]'
              _params[:item][:owner_uid] = "#{Site.user.id}"
              _params[:item][:creator_uid] = "#{Site.user.id}"
              _params[:item][:creator_gid] = "#{Site.user_group.id}"
              _params[:item][:is_public] = "3"
              _params[:init][:repeat_mode] = "1"

              if !row[5].blank? && row[5].upcase == 'TRUE' # 終日
                _params[:item][:ed_at] = "#{row[1]} #{row[4]}"
                _params[:item][:allday] = '1'
                _params[:item][:allday_radio_id] = ["2"]
              end

              item = Gw::Schedule.new()

              if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(item, _params, :create)
                # 新着情報(新規作成時)を作成
                item.build_created_remind
                success += 1
              else
                error_msg += "#{i}" + t("rumi.schedule.import.message.csv.create_fail") + "<br />\n"
                error_msg += item.errors.full_messages.join("<br />\n")
                error += 1
                _csv << item.errors.full_messages.join("")
                csv_result << _csv
              end
            else
              if i == 1
                error_msg += t("rumi.schedule.import.message.csv.mismatched")
              end
              _csv << t("rumi.schedule.import.message.csv.mismatched")
              csv_result << _csv
              error += 1
            end
          end
        end
      end

    end

    _error_msg = t("rumi.schedule.import.message.success") + '<br />' +
      t("rumi.schedule.import.message.result") + '<br />' +
      t("rumi.schedule.import.message.effectiveness") + success.to_s + t("rumi.schedule.import.message.effectiveness_tail") + 
      t("rumi.schedule.import.message.invalid") + error.to_s + t("rumi.schedule.import.message.invalid_tail") + '<br />' +
      ( error_msg.blank? ? '' : t("rumi.schedule.import.message.invalid_result") + '<br />' ) +
      error_msg

    if par_item[:file_type] == 'ical'
      if success > 0
        flash[:notice] = _error_msg
        redirect_to "/gw/schedules/setting_ind"
      else
        flash.now[:notice] = _error_msg
        respond_to do |format|
          format.html { render :action => "import" }
        end
      end
    elsif par_item[:file_type] == 'csv'
      if error > 0
        effectiveness = t("rumi.schedule.import.message.effectiveness") + success.to_s + t("rumi.schedule.import.message.effectiveness_tail")
        invalid = t("rumi.schedule.import.message.invalid") + error.to_s + t("rumi.schedule.import.message.invalid_tail")
        csv_result << [effectiveness + invalid]
        file = Gw::Script::Tool.ary_to_csv(csv_result)
        send_data NKF::nkf('-s', file), :filename => "result.csv"
      else
        if success > 0
          flash[:notice] = _error_msg
          redirect_to import_gw_schedule_settings_path
        else
          flash.now[:notice] = _error_msg
          respond_to do |format|
            format.html { render :action => "import" }
          end
        end
      end
    end
  end

  def potal_display
    key = 'schedules'
    hu = nz(Gw::Model::UserProperty.get(key.singularize), nil)
    if hu.blank?
      hash = {key => {}}
      trans_raw = Gw::NameValue.get('yaml', nil, "gw_#{key}_settings_ind")
      cols = trans_raw['_cols'].split(":")

      default = Gw::NameValue.get('yaml', nil, "gw_#{key}_settings_system_default")
      cols.each do |col|
        hash[key][col] = default[col].to_s
      end
      hu = hash
    end

    hu[key]['view_portal_schedule_display'] = '1' unless hu[key].key?('view_portal_schedule_display')

    hu_update = hu[key]
    if hu_update['view_portal_schedule_display'] == '1'
      hu_update['view_portal_schedule_display'] = '0'
    else
      hu_update['view_portal_schedule_display'] = '1'
    end

    ret = Gw::Model::UserProperty.save(key.singularize, hu, {})
    redirect_to root_url
  end
end

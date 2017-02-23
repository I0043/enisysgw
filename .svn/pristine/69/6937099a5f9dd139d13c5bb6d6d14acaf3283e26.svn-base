# encoding: utf-8
class Gw::ScheduleProp < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :prop, :polymorphic => true

  def self.is_admin?(genre, extra_flag, options={})
    _ef = nz(extra_flag, 'other')
    return true if _ef == 'other'
    return false
  end

  def owner_s(options={})
    genre = prop.class.name.split('::').last.gsub(/^Prop/, '').downcase
    owner_class = prop.extra_flag
    case genre
    when 'other'
      prop.gname
    else
      prop_classes_raw[genre][owner_class]
    end
  end

  def _name
    self.prop.name
  end

  alias :_prop_name :_name

  def _owner
    self.schedule.owner_uname
  end

  def _subscriber
    self.schedule.owner_gname
  end

  def _prop_stat
    self.prop_stat_s
  end

  def is_return_genre?
    if self.prop_type == "Gw::PropOther"
      return "other"
    end
  end

  def self.is_prop_edit?(prop_id, genre, options = {})
    if options.key?(:is_gw_admin)
      is_gw_admin = options[:is_gw_admin]
    else
      is_gw_admin = Gw.is_admin_admin?
    end

    flg = true

    if options[:prop].blank?
      prop = Gw::PropOther.find(prop_id)
    else
      prop = options[:prop]
    end

    unless prop.blank?
      if !is_gw_admin
        flg = Gw::PropOtherRole.is_edit?(prop_id) && (prop.reserved_state == 1 || prop.delete_state == 0)
      end
      if prop.reserved_state == 0 || prop.delete_state == 1
        flg = false
      end
    else
      flg = false
    end

    return flg
  end

  def self.getajax(params)
    begin
      st_at = Gw.to_time(params[:st_at]) rescue nil
      ed_at = Gw.to_time(params[:ed_at]) rescue nil
      schedule_id = nz(params[:schedule_id], 0).to_i rescue 0

      if st_at.blank? || ed_at.blank? || st_at >= ed_at
        item = {errors: I18n.t("rumi.schedule_prop.message.date_valid")}
      else
        @index_order = 'extra_flag, sort_no, gid, name'
        cond_props_within_terms = "SELECT distinct prop_id FROM gw_schedules"
        cond_props_within_terms.concat " left join gw_schedule_props on gw_schedules.id =  gw_schedule_props.schedule_id"
        cond_props_within_terms.concat " where"
        cond_props_within_terms.concat " gw_schedules.delete_state = 0"
        cond_props_within_terms.concat " and gw_schedules.id <> #{schedule_id}" unless schedule_id
        cond_props_within_terms.concat " and gw_schedules.ed_at > '#{Gw.datetime_str(st_at)}'"
        cond_props_within_terms.concat " and gw_schedules.st_at < '#{Gw.datetime_str(ed_at)}'"
        cond_props_within_terms.concat " order by prop_id"
        cond = "piwt.prop_id is null"
        cond.concat " and gw_prop_others.delete_state = 0 and gw_prop_others.reserved_state = 1"
        type_id = params[:type_id].split("_") if !params[:type_id].blank?
        if nz(type_id[1], 0).to_i != 0
          if type_id[0]=="type"
            cond.concat " and type_id = " + type_id[1]
          else
            id = type_id[1]
            g_cond = "id = #{id} or parent_id = #{id}"
            group = Gw::PropGroup.where(g_cond).select("id")
            if !group.blank?
              cnt=0
              group.each do | g|
                g_cond.concat " or " if cnt!=0
                g_cond = " prop_group_id = #{g.id} " if cnt==0
                g_cond.concat " prop_group_id = #{g.id}" if cnt!=0
                cnt = 1
              end
            end
            group_set = Gw::PropGroupSetting.where(g_cond).select("prop_other_id")
            if !group_set.blank?
              cond.concat " and ("
              cnt = 0
              group_set.each do | set|
                cond.concat " or " if cnt!=0
                cnt = 1
                cond.concat "gw_prop_others.id = #{set.prop_other_id}"
              end
              cond.concat " ) "
            else
              cond.concat " and type_id=0 "
            end
          end
        end

        joins = "left join (#{cond_props_within_terms}) piwt on gw_prop_others.id = piwt.prop_id"

        item = Gw::PropOther.joins(joins).where(cond).order("type_id, gid, sort_no, name").select{|x|
          if @gw_admin
            true
          else
            (Gw::PropOtherRole.is_admin?(x.id) &&
             Gw::PropOtherRole.is_edit?(x.id)) ||
             (Gw::PropOtherRole.is_edit?(x.id) &&
              ((x.d_load_st.blank? ||
                x.d_load_st <= Time.parse(params[:st_at])) &&
               (x.d_load_ed.blank? ||
                x.d_load_ed >= Time.parse(params[:ed_at]))) &&
              x.available?(params[:ed_at]))
          end
          }.collect{|x| [x.id, x.name.to_s, x.gname]}
        item = {errors: I18n.t("rumi.ajax.message.no_hit")} if item.blank?
      end
      return item
    rescue
      return {errors: I18n.t("rumi.ajax.message.error")}
    end
  end
end

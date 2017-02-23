# encoding: utf-8
class Gw::PropOther < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name, :type_id
  has_many :schedule_props, :class_name => 'Gw::ScheduleProp', :as => :prop
  has_many :schedules, :through => :schedule_props
  has_many :images, -> {order("gw_prop_other_images.id")}, :primary_key => 'id', :foreign_key => 'parent_id', :class_name => 'Gw::PropOtherImage'
  has_many :prop_other_roles, -> {order("gw_prop_other_roles.id")}, :foreign_key => :prop_id, :class_name => 'Gw::PropOtherRole'
  belongs_to :prop_type, :foreign_key => :type_id, :class_name => 'Gw::PropType'

  after_save :delete_cache_admin_first
  before_destroy :delete_cache_admin_first

  def delete_cache_admin_first
    Rails.cache.delete(admin_first_id_cache_key)
  end

  def self.get_select
    _conditions = ""
    return where(_conditions).select("id,name").order('extra_flag, gid, sort_no, name').map{|x| [ x.name, x.id ]}
  end

  def is_my_belong?
    mygid = Core.user_group.id
    if mygid.to_s == gid.to_s
      return true
    else
      return false
    end
  end

  def self.is_my_belong?(prop_id = nil, gid = Core.user_group.id)
    return false if prop_id.blank? || gid.blank?
    prop_other = where("id = #{prop_id}").first
    if gid.to_s == prop_other.gid.to_s
      return true
    else
      return false
    end
  end

  def self.is_my_belong_params?(params, gid = Core.user_group.id)
    flg = true
    if params[:s_genre] == "other"
      if params[:be] == "other"
        flg = false
      elsif !params[:prop_id].blank?
        unless is_my_belong?(params[:prop_id], gid)
          flg = false
        end
      end
    end
    return flg
  end

  def get_admin_gname
    role = Gw::PropOtherRole.where("prop_id = #{self.id}").first
    group = System::Group.find(role.gid)
    return group.name
  end

  def admin_gids
    self.prop_other_roles.select{|x| x.auth == 'admin'}.collect{|x| x.gid}
  end

  def editor_gids
    self.prop_other_roles.select{|x| x.auth == 'edit'}.collect{|x| x.gid}
  end

  def reader_gids
    self.prop_other_roles.select{|x| x.auth == 'read'}.collect{|x| x.gid}
  end

  def self.get_parent_groups
    parent_groups = System::GroupHistory.where("level_no = 2").order("sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    return parent_groups
  end

  def admin(pattern = :show)
    admin = Array.new
    groups = System::Group.
      where(id: self.admin_gids).
      order("level_no,  sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    groups.each do |group|
      name = group.name
      admin << [name] if pattern == :show
      admin << ["", group.id, name] if pattern == :select
    end
    return admin.uniq
  end

  def admin_first_id_cache_key
    return "admin_first_id_#{self.id}"
  end

  def get_admin_first_id(parent_groups = Gw::PropOther.get_parent_groups)
    if self.gid.present?
      return self.gid
    else
      Cache.load(admin_first_id_cache_key) { admin_first_id(parent_groups) }
    end
  end

  def admin_first_id(parent_groups = Gw::PropOther.get_parent_groups)
    groups = Array.new
    gids = self.admin_gids
    if gids.length > 1
      groups = System::GroupHistory.where("id in (?)", gids).order("level_no,  sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    elsif gids.length == 1
      return gids[0]
    end
    parent_groups.each do |parent_group|
      groups.each do |group|
        g = System::GroupHistory.find_by(id: group.id)
        if g.present?
          if g.id == parent_group.id
            return g.id
          elsif g.parent_id == parent_group.id
            if g.state == "disabled"
            else
              return g.id
            end
          end
        end
      end
    end
  end

  def editor(pattern = :show)
    editor = Array.new
    gids = self.editor_gids
    if !gids.index(0).nil?
      editor << [I18n.t("rumi.select.no_limit")] if pattern == :show
      editor << ["", 0, I18n.t("rumi.select.no_limit")] if pattern == :select
    end
    groups = System::Group.
      where(id: gids).
      order("level_no,  sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    groups.each do |group|
      name = group.name
      editor << [name] if pattern == :show
      editor << ["", group.id, name] if pattern == :select
    end
    return editor.uniq
  end

  def reader(pattern = :show)
    reader = Array.new
    gids = self.reader_gids
    if !gids.index(0).nil?
      reader << [I18n.t("rumi.select.no_limit")] if pattern == :show
      reader << ["", 0, I18n.t("rumi.select.no_limit")] if pattern == :select
    end
    groups = System::Group.
      where(id: gids).
      order("level_no,  sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    groups.each do |group|
      name = group.name
      reader << [name] if pattern == :show
      reader << ["", group.id, name] if pattern == :select
    end
    return reader.uniq
  end

  def is_auth_group?(auth, prop_id, gid)
    items = self.prop_other_roles.select{|x| x.auth == auth && x.prop_id == prop_id && x.gid == gid}
    if items.length > 0
      return true
    else
      return false
    end
  end

  def is_admin_or_editor_or_reader?(gid = Core.user_group.id)
    item = Gw::PropOtherRole.select("id").where("prop_id = #{self.id} and gid in (#{gid}, #{Core.user_group.parent_id}, 0)")

    if item.length > 0
      return true
    else
      return false
    end
  end

  def admin_editor_reader(pattern = :select)
    admin_groups = []
    edit_groups = []
    read_groups = []

    self.prop_other_roles.each do |role|

      if role.auth == 'admin' && !role.group.blank?
        if pattern == :select
          admin_groups.push ["", role.group.id, role.group.name]
        elsif pattern == :name
          admin_groups.push [role.group.name]
        end

      elsif role.auth == 'edit' && !role.group.blank?
        if pattern == :select
          edit_groups.push ["", role.group.id, role.group.name]
        elsif pattern == :name
          edit_groups.push [role.group.name]
        end

      elsif role.auth == 'read'
        if pattern == :select
          if role.gid == 0
            read_groups.push ["", 0, I18n.t("rumi.select.no_limit")]
          elsif !role.group.blank?
            read_groups.push [2, role.group.id, role.group.name]
          end
        elsif pattern == :name
          if role.gid == 0
            read_groups.push [I18n.t("rumi.select.no_limit")]
          elsif !role.group.blank?
            read_groups.push [role.group.name]
          end
        end

      end
    end

    if pattern == :select
      return admin_groups.to_json, edit_groups.to_json, read_groups.to_json
    elsif pattern == :name
      return admin_groups, edit_groups, read_groups
    end
  end

  def save_with_rels(params, mode, options={})

    admin_groups = ::JsonParser.new.parse(params[:item][:admin_json])
    edit_groups = ::JsonParser.new.parse(params[:item][:editors_json])
    read_groups = ::JsonParser.new.parse(params[:item][:readers_json])

    gid = nz(params[:item]['sub']['gid'])
    uid = nz(params[:item]['sub']['uid'])
    ad_gnames = []
    now = Time.now

    if params[:item][:sort_no].blank?
      params[:item][:sort_no] = 0
    elsif /^[0-9]+$/ =~ params[:item][:sort_no] && params[:item][:sort_no].to_i >= 0 && params[:item][:sort_no].to_i <= 999999999
    else
      self.errors.add :sort_no, I18n.t("rumi.error.number9")
    end

    if params[:item][:d_load_st].present?
      begin
        d_load_st = Date.strptime(params[:item][:d_load_st], I18n.t("rumi.strftime.date2"))
                        .beginning_of_day
      rescue
        self.errors.add :d_load_st, I18n.t("rumi.error.date")
      end
    end

    if params[:item][:d_load_ed].present?
      begin
        d_load_ed = Date.strptime(params[:item][:d_load_ed], I18n.t("rumi.strftime.date2"))
                        .end_of_day
      rescue
        self.errors.add :d_load_ed, I18n.t("rumi.error.date")
      end
    end

    if (limit_month = params[:item][:limit_month]).present?
      unless limit_month =~ /^[0-9]*$/
        self.errors.add :limit_month, I18n.t("rumi.error.number")
      end
    end

    if params[:item][:d_load_st] =~ /\d{4}-\d{2}-\d{2}/ && params[:item][:d_load_ed] =~ /\d{4}-\d{2}-\d{2}/ && self.errors.size == 0
      self.errors.add :d_load_st, I18n.t("rumi.error.prop_other.d_load_st") if d_load_st > d_load_ed
    elsif params[:item][:d_load_st] =~ /\d{1,2} [A-Za-z]{3} \d{4}/ && params[:item][:d_load_ed] =~ /\d{1,2} [A-Za-z]{3} \d{4}/ && self.errors.size == 0
      self.errors.add :d_load_st, I18n.t("rumi.error.prop_other.d_load_st") if d_load_st > d_load_ed
    end

    if params[:item][:name].blank?
      self.errors.add :name, I18n.t("rumi.error.input")
    end

    if admin_groups.empty?
      
      self.errors.add I18n.t("rumi.prop_other.th.admin").to_sym, I18n.t("rumi.error.registration")
    end
    if edit_groups.empty?
      self.errors.add I18n.t("rumi.prop_other.th.editor").to_sym, I18n.t("rumi.error.registration")
    else
      count = 0
      no_limit = false
      edit_groups.each_with_index{|edit_group, y|
        count += 1
        if edit_group[1] == "0"
          no_limit = true
        end
      }
      if no_limit && count > 1
        self.errors.add I18n.t("rumi.prop_other.th.editor").to_sym, I18n.t("rumi.error.prop_other.with_no_limit_group")
      end
    end
    if read_groups.present?
      count = 0
      no_limit = false
      read_groups.each_with_index{|read_group, y|
        count += 1
        if read_group[1] == "0"
          no_limit = true
        end
      }
      if no_limit && count > 1
        self.errors.add I18n.t("rumi.prop_other.th.reader").to_sym, I18n.t("rumi.error.prop_other.with_no_limit_group")
      end
    end

    limit_flg = false

    admin_first_gid = gid
    admin_first_gname = ""
    admin_groups.each_with_index{|admin_group, y|
      ad_gid = admin_group[1]
      ad_gname = admin_group[2]
      if y == 0
        admin_first_gid = ad_gid
        admin_first_gname = ad_gname
      end

      limit = Gw::PropOtherLimit.limit_count(ad_gid)
      count = Gw::PropOtherRole.admin_group_count(ad_gid)
      if limit <= count
        limit_flg = true
        ad_gnames << [ad_gname]
      end
    }

    if limit_flg
      self.errors.add I18n.t("rumi.prop_other.th.admin").to_sym, I18n.t("rumi.prop_other.message.errors.input_limit_over", group_names: Gw.join([ad_gnames], '、'))
    end

    self.reserved_state = params[:item][:reserved_state]
    self.sort_no = params[:item][:sort_no]
    self.name    = params[:item][:name]
    self.type_id   = params[:item][:type_id]
    self.comment   = params[:item][:comment]
    self.extra_flag   = params[:item][:extra_flag]
    self.extra_data   = params[:item][:extra_data]
    if self.errors.size == 0
      self.d_load_st   = d_load_st
      self.d_load_ed   = d_load_ed
    else
      self.d_load_st   = params[:item][:d_load_st]
      self.d_load_ed   = params[:item][:d_load_ed]
    end
    self.limit_month = params[:item][:limit_month]

    if mode == :create
      self.creator_uid = uid
      self.updater_uid = uid
      self.created_at = 'now()'
      self.updated_at = 'now()'
    elsif mode == :update
      self.updater_uid = uid
      self.updated_at = now.strftime("%Y-%m-%-d %-H:%-M")
    end

    self.gid = admin_first_gid
    self.gname = admin_first_gname

    if self.errors.size == 0 && self.editable? && self.save()
      prop_id = self.id

      Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'admin'").destroy_all
      admin_groups.each_with_index{|admin_group, y|
        new_admin_group = Gw::PropOtherRole.new()
        new_admin_group.gid = admin_group[1]
        new_admin_group.prop_id = prop_id
        new_admin_group.auth = 'admin'
        new_admin_group.created_at = 'now()'
        new_admin_group.updated_at = 'now()'
        new_admin_group.save
      }

      old_edit_groups = Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'edit'")
      old_edit_groups.each_with_index{|old_edit_role, x|
        use = 0
        edit_groups.each_with_index{|edit_group, y|
          if old_edit_role.gid.to_s == edit_group[1].to_s
              edit_groups.delete_at(y)
              use = 1
          end
        }
        if use == 0
          old_edit_role.destroy
        end
      }
      edit_groups.each_with_index{|edit_group, y|
        new_edit_role = Gw::PropOtherRole.new()
        new_edit_role.gid = edit_group[1]
        new_edit_role.prop_id = prop_id
        new_edit_role.auth = 'edit'
        new_edit_role.created_at = 'now()'
        new_edit_role.updated_at = 'now()'
        new_edit_role.save
      }

      old_read_groups = Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'read'")
      old_read_groups.each_with_index{|old_role, x|
        use = 0
        read_groups.each_with_index{|read_group, y|
          if old_role.gid.to_s == read_group[1].to_s
            read_groups.delete_at(y)
            use = 1
          end
        }
        if use == 0
          old_role.destroy
        end
      }
      read_groups.each_with_index{|read_group, y|
        new_role = Gw::PropOtherRole.new()
        new_role.gid = read_group[1]
        new_role.prop_id = prop_id
        new_role.auth = 'read'
        new_role.created_at = 'now()'
        new_role.updated_at = 'now()'
        new_role.save
      }
    end

  end


  def save_with_rels_csv(params, mode, options={})

    admin_groups = ::JsonParser.new.parse(params[:item][:admin_json])
    edit_groups = ::JsonParser.new.parse(params[:item][:editors_json])

    gid = nz(params[:item][:gid])
    uid = nz(params[:item][:creator_uid])
    ad_gnames = []
    now = Time.now

    if params[:item][:sort_no].blank?
      params[:item][:sort_no] = 0
    elsif /^[0-9]+$/ =~ params[:item][:sort_no] && params[:item][:sort_no].to_i >= 0 && params[:item][:sort_no].to_i <= 99999999999
    else
      self.errors.add :sort_no, I18n.t("rumi.error.number11")
    end

    if params[:item][:name].blank?
      self.errors.add :name, I18n.t("rumi.error.input")
    end

    if admin_groups.empty?
      self.errors.add I18n.t("rumi.prop_other.th.admin").to_sym, I18n.t("rumi.error.registration")
    end
    if edit_groups.empty?
      self.errors.add I18n.t("rumi.prop_other.th.editor").to_sym, I18n.t("rumi.error.registration")
    end

    limit_flg = false

    admin_first_gid = gid
    admin_first_gname = ""
    admin_groups.each_with_index{|admin_group, y|
      ad_gid = admin_group[1]
      ad_gname = admin_group[2]
      if y == 0
        admin_first_gid = ad_gid
        admin_first_gname = ad_gname
      end

      limit = Gw::PropOtherLimit.limit_count(ad_gid)
      count = Gw::PropOtherRole.admin_group_count(ad_gid)
      if limit <= count
        limit_flg = true
        ad_gnames << [ad_gname]
      end
    }

    if limit_flg
      self.errors.add I18n.t("rumi.prop_other_limit.name").to_sym, I18n.t('rumi.prop_other.message.errors.inport_limit_over')
    end

    self.reserved_state = params[:item][:reserved_state]
    self.sort_no = params[:item][:sort_no]
    self.name    = params[:item][:name]
    self.type_id   = params[:item][:type_id]
    self.comment   = params[:item][:comment]
    self.extra_flag   = params[:item][:extra_flag]
    self.extra_data   = params[:item][:extra_data]

    if mode == :create
      self.creator_uid = uid
      self.updater_uid = uid
      self.created_at = 'now()'
      self.updated_at = 'now()'
    elsif mode == :update
      self.updater_uid = uid
      self.updated_at = 'now()'
    end

    self.gid = admin_first_gid
    self.gname = admin_first_gname

    if self.errors.size == 0 && self.editable? && self.save()
      prop_id = self.id

      Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'admin'").destroy_all
      admin_groups.each_with_index{|admin_group, y|
        new_admin_group = Gw::PropOtherRole.new()
        new_admin_group.gid = admin_group[1]
        new_admin_group.prop_id = prop_id
        new_admin_group.auth = 'admin'
        new_admin_group.created_at = 'now()'
        new_admin_group.updated_at = 'now()'
        new_admin_group.save
      }

      old_edit_groups = Gw::PropOtherRole.where("prop_id = #{prop_id} and auth = 'edit'")
      old_edit_groups.each_with_index{|old_edit_role, x|
        use = 0
        edit_groups.each_with_index{|edit_group, y|
          if old_edit_role.gid.to_s == edit_group[1].to_s
              edit_groups.delete_at(y)
              use = 1
          end
        }
        if use == 0
          old_edit_role.destroy
        end
      }
      edit_groups.each_with_index{|edit_group, y|
        new_edit_role = Gw::PropOtherRole.new()
        new_edit_role.gid = edit_group[1]
        new_edit_role.prop_id = prop_id
        new_edit_role.auth = 'edit'
        new_edit_role.created_at = 'now()'
        new_edit_role.updated_at = 'now()'
        new_edit_role.save
      }
    else
    end
  end

  def get_type_class
    case self.type_id
    when 200
      class_s = "room"
    when 100
      class_s = "car"
    else
      class_s = "other"
    end
    return class_s
  end

  def available?(value)
    if self.limit_month
      case value
      when String
        date = Date.parse(value)
      when Date
        date = value
      else
        return false
      end
      today = Date.today
      d = today >> (self.limit_month + 1)
      limit = Date.new(d.year, d.month, 1)
      date < limit
    else
      true
    end
  end

  # === 施設選択UIにて表示する選択肢の作成を行うメソッド
  #
  # ==== 引数
  #  * value_method: Symbol e.g. :code
  # ==== 戻り値
  #  [value, display_name]
  def to_select_option(value_method = :id)
    return [Gw.trim(self.name), self.send(value_method)]
  end

  def self.affiliated_props_to_select_option(target_type_id, login_user_id = nil)
    target = target_type_id.split('_')
    props = Gw::PropOther.where(type_id: target[1]) if target[0] == "type"
    props = Gw::PropOther.where(type_id: target[1]) if target[0] == "group"

    return props.map { |prop| prop }
  end

  def states
    [[I18n.t("rumi.state.parmit"), '1'], [I18n.t("rumi.state.improper"), '0']]
  end
end

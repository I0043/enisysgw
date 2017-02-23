# encoding: utf-8
class System::Admin::LdapTemporariesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.ldap_temporary.name")
    @piece_head_title = t("rumi.ldap_temporary.name")
    @side = "setting"
    @current_no = 2

    return error_auth unless Core.user.has_auth?(:manager)
    return render text: t("rumi.ldap_temporary.message.connect_fail"), layout: true unless Core.ldap.connection
    @role_admin = @admin = System::User.is_admin?
    return authentication_error(403) unless @admin == true
  end

  def find_groups
    groups = Core.ldap.group.children
    return groups
  end

  def index
    case params[:do]
    when 'preview'
      return _preview
    when 'create'
      return _create
    end

    @items = System::LdapTemporary.group(:version).order(version: :desc).paginate(page: params[:page])
  end

  def show
    tmp = System::LdapTemporary.where(version: params[:id], parent_id: 0, data_type: 'group')
    @groups = tmp.order(:code)  # groups level_no=2 all

    case params[:do]
    when 'synchro'
      return _synchro
    end
  end

  def destroy
    System::LdapTemporary.where('version = ?', params[:id]).delete_all
    message = t("rumi.ldap_temporary.message.delete") + "［ version: #{params[:id]} ］"
    redirect_to ({:action => 'index'}), :notice => message
  end

private
  def _preview
    if find_groups
      _index @text = t("rumi.ldap_temporary.message.connect")
    else
      _index @text = t("rumi.ldap_temporary.message.connect_fail")
    end
  end


  def _create
    require 'time'

    time_base = Time.parse("1970-01-01T00:00:00Z")
    @version = (Time.now - time_base).to_i
    @groups  = find_groups

    sort_no = 0
    next_sort_no = Proc.new do
      sort_no += 10
    end

    @groups.each do |d|
      next unless d.synchro_target?
      d_db = System::LdapTemporary.new({
        :parent_id => 0,
        :version   => @version,
        :data_type => 'group',
        :code      => d.code,
        :sort_no   => next_sort_no.call,
        :name      => d.name,
        :name_en   => d.name_en,
        :email     => d.email,
      })
      d_db.save

      d.children.each do |s|
        s_db = System::LdapTemporary.new({
          :parent_id => d_db.id,
          :version   => @version,
          :data_type => 'group',
          :code      => s.code,
          :sort_no   => next_sort_no.call,
          :name      => s.name,
          :name_en   => s.name_en,
          :email     => s.email,
        })
        s_db.save

        s.users.each do |u|
          u_db = System::LdapTemporary.new({
            :parent_id => s_db.id,
            :version   => @version,
            :data_type => 'user',
            :code      => u.uid,
            :sort_no   => u.sort_no,
            :kana      => u.kana,
            :name      => u.name,
            :name_en   => u.name_en,
            :email     => u.email,
            :official_position => u.official_position,
            :assigned_job =>  u.assigned_job
          })
          u_db.save
        end
      end
    end

    flash[:notice] = t("rumi.ldap_temporary.message.create") + "［ version: #{@version} ］"
    redirect_to :action => :show, :id => @version
  end


  def quote(val)
    System::GroupHistory.connection.quote(val)
  end

  def _synchro
    @version = params[:id]
    @errors  = []
    tmp = System::LdapTemporary.where(version: params[:id], parent_id: 0, data_type: 'group')

    @groups = tmp.order(:code)

    System::User.where("ldap = 1").update_all("ldap_version = NULL")
    System::Group.where("ldap = 1").update_all("ldap_version = NULL")
    System::GroupHistory.where("ldap = 1").update_all("ldap_version = NULL")

    group_sort_no = 100000000
    group_next_sort_no = Proc.new do
      group_sort_no = group_sort_no + 10
    end

    @groups.each do |d|
      cond = "parent_id = 1 and level_no = 2 and code = '#{d.code}' "
      order = "code"
      group = System::Group.where(cond).order(order).first || System::Group.new

      group.parent_id    = 1
      group.state        = 'enabled'
      group.updated_at   = Core.now
      group.name         = d.name
      group.name_en      = d.name_en
      group.email        = d.email
      group.level_no     = 2
      group.sort_no    ||= group_next_sort_no.call

      group.ldap_version = @version

      group.ldap         = 1
      group.code         = d.code
      group.version_id   = 0
      group.end_at       = nil
      group.start_at   ||= Date.today
      group.created_at ||= Core.now
      group.category     = 0

      if group.id
        @errors << "group2-u : #{d.code}-#{d.name}" && next unless group.save
      else
        @errors << "group2-n : #{d.code}-#{d.name}" && next unless group.save
      end

      d.children.each do |s|
        s_cond = "parent_id = #{group.id} and level_no = 3 and code = '#{s.code}'"
        s_order = "code"
        c_group = System::Group.where(s_cond).order(s_order).first || System::Group.new

        c_group.parent_id    = group.id
        c_group.state        = 'enabled'
        c_group.updated_at   = Core.now
        c_group.name         = s.name
        c_group.name_en      = s.name_en
        c_group.email        = s.email
        c_group.level_no     = 3
        c_group.sort_no    ||= group_next_sort_no.call

        c_group.ldap_version = @version

        c_group.ldap         = 1
        c_group.version_id   = 0
        c_group.code         = s.code.to_s
        c_group.end_at       = nil
        c_group.start_at   ||= Date.today
        c_group.created_at ||= Core.now
        c_group.category     = 0

        if c_group.id
          @errors << "group3-u : #{s.code} - #{s.name}" && next unless c_group.save
        else
          @errors << "group3-n : #{s.code} - #{s.name}" && next unless c_group.save
        end

        s.users.each do |u|
          cond = "code='#{u.code}'"
          user = System::User.where(cond).first || System::User.new

          user.updated_at   = Core.now
          user.state        = 'enabled'
          user.ldap         = 1
          user.name         = u.name
          user.name_en      = u.name_en
          user.email        = u.email
          user.ldap_version = @version
          user.code         = u.code
          user.sort_no      = u.sort_no
          user.kana         = u.kana
          user.official_position  = u.official_position
          user.assigned_job       = u.assigned_job
          user.created_at ||= Core.now
          user.auth_no    ||= 3

          user.in_group_id  = c_group.id

          if user.id
            @errors << "user-u : #{u.code} - #{u.name}" && next unless user.save
          else
            @errors << "user-n : #{u.code} - #{u.name}" && next unless user.save
          end

        end ##/users
      end ##/sections
    end ##/departments

    cond = "ldap = 1 AND ldap_version IS NULL"
    System::User.where(cond).update_all("state = 'disabled'")
    System::Group.where(cond).update_all("state = 'disabled'")
    System::Group.where(cond).update_all("end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")
    System::GroupHistory.where(cond).update_all("state = 'disabled'")
    System::GroupHistory.where(cond).update_all("end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'")

    sql  = "UPDATE system_users_groups"
    sql += " INNER JOIN system_users ON system_users.id = system_users_groups.user_id"
    sql += " SET system_users_groups.end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    sql += " WHERE system_users.ldap = 1 AND system_users.ldap_version IS NULL AND system_users_groups.end_at IS NULL AND system_users_groups.job_order = 0"
    System::UsersGroup.connection.execute(sql)

    sql  = "UPDATE system_users_group_histories"
    sql += " INNER JOIN system_users ON system_users.id = system_users_group_histories.user_id"
    sql += " SET system_users_group_histories.end_at = '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    sql += " WHERE system_users.ldap = 1 AND system_users.ldap_version IS NULL AND system_users_group_histories.end_at IS NULL AND system_users_group_histories.job_order = 0"
    System::UsersGroupHistory.connection.execute(sql)

    System::User.where(cond).update_all("ldap = 0")
    System::Group.where(cond).update_all("ldap = 0")
    System::GroupHistory.where(cond).update_all("ldap = 0")

    Rails.cache.clear

    if @errors.size > 0
      flash[:notice] = 'Error: <br />' + @errors.join('<br />')
    else
      flash[:notice] = t("rumi.ldap_temporary.message.synchro")
    end
    redirect_to url_for(:action => :show)
  end

  def _synchronize
    rels = []
    System::User.where(:ldap => 0).each do |user|
      rels << {
        :user_id => user.id,
        :groups  => user.groups.collect{|i| i.id}
      }
    end

    _synchronize_groups
    _synchronize_users

    rels.each do |rel|
      rel[:groups].each do |group_id|
        System::UsersGroup.create({
          :user_id  => rel[:user_id],
          :group_id => group_id,
        })
      end
    end

    flash[:notice] = t("rumi.ldap_temporary.message.synchro")
    redirect_to url_for(:action => :show)
  end

  def _synchronize_groups
    quote = Proc.new do |val|
      System::Group.connection.quote(val)
    end

    @groups = System::LdapGroup.find_all_as_tree
    System::Group.where('id != 1').destroy_all

    @groups.each do |dep|
      sql = "INSERT INTO #{System::Group.table_name} (" +
        " id, parent_id, state, created_at, updated_at, level_no, name, name_en, email" +
        " ) VALUES (" +
        " #{quote.call(dep[:id])}" +
        " ,#{quote.call(dep[:parent_id])}" +
        " ,'enabled'" +
        " ,#{quote.call(Core.now)}" +
        " ,#{quote.call(Core.now)}" +
        " ,#{quote.call(dep[:level_no])}" +
        " ,#{quote.call(dep[:name])}" +
        " ,#{quote.call(dep[:name_en])}" +
        " ,#{quote.call(dep[:email])}" +
        ")"
      System::Group.connection.execute(sql) unless dep[:duplicated]

      dep[:sections].each do |sec|
        sql = "INSERT INTO #{System::Group.table_name} (" +
          " id, parent_id, state, created_at, updated_at, level_no, name, name_en, email" +
          " ) VALUES (" +
          " #{quote.call(sec[:id])}" +
          " ,#{quote.call(sec[:parent_id])}" +
          " ,'enabled'" +
          " ,#{quote.call(Core.now)}" +
          " ,#{quote.call(Core.now)}" +
          " ,#{quote.call(sec[:level_no])}" +
          " ,#{quote.call(sec[:name])}" +
          " ,#{quote.call(sec[:name_en])}" +
          " ,#{quote.call(sec[:email])}" +
          ")"
        System::Group.connection.execute(sql) unless sec[:duplicated]
      end
    end
  end

  def _synchronize_users
    quote = Proc.new do |val|
      System::User.connection.quote(val)
    end

    @users = System::LdapUser.find_all_as_tree

    System::User.where('ldap = 1').destroy_all

    @users.each do |user|
      next if user[:duplicated]

      sql = "INSERT INTO #{System::User.table_name} (" +
        " id, state, created_at, updated_at, ldap, name, email" +
        " ) VALUES (" +
        " #{quote.call(user[:id])}" +
        " ,'enabled'" +
        " ,#{quote.call(Core.now)}" +
        " ,#{quote.call(Core.now)}" +
        " ,'1'" +
        " ,#{quote.call(user[:name])}" +
        " ,#{quote.call(user[:email])}" +
        ")"
      System::User.connection.execute(sql)

      System::UsersGroup.create({
        :user_id => user[:id],
        :group_id => user[:group_id],
      })
    end
  end
end

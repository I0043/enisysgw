# encoding: utf-8
class Gwbbs::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout :select_layout
  protect_from_forgery :except => [:forward_select]

  def pre_dispatch
    Page.title = I18n.t("rumi.bbs.name")
    @piece_head_title = I18n.t("rumi.bbs.name")
    @side = "gwbbs"
    params[:limit] = 100
  end

  def index
    if @gw_admin
      admin_index
    else
      readable_index
    end
  end

  def forward_select
    @gwbbs_form_url = "/gwbbs/docs/forward"
    @gwbbs_target_name = "gwbbs_form"

    if @gw_admin
      admin_index
    else
      writeable_index
    end
  end

  def admin_index
    @items = Gwbbs::Control.where(state: 'public', view_hide: 1)
                           .order('sort_no, docslast_updated_at DESC')
                           .paginate(page: params[:page]).limit(params[:limit])
  end

  def readable_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      # 閲覧権限または、管理者権限が存在すること
      d.and "sql", "(gwbbs_roles.role_code = 'r' AND gwbbs_roles.group_code = '0' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '0')"
    }
    for group in Core.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        # 閲覧権限または、管理者権限が存在すること
        d.and "sql", "(gwbbs_roles.role_code = 'r' AND gwbbs_roles.group_code = '#{group.code}' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '#{group.code}')"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          # 閲覧権限または、管理者権限が存在すること
          d.and "sql", "(gwbbs_roles.role_code = 'r' AND gwbbs_roles.group_code = '#{group.parent.code}' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '#{group.parent.code}')"
        }
      end
    end

    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      # 閲覧権限または、管理者権限が存在すること
      d.and "sql", "(gwbbs_roles.role_code = 'r' AND gwbbs_roles.user_code = '#{Core.user.code}' OR gwbbs_adms.user_code = '#{Core.user.code}')"
    }
    join = "LEFT JOIN gwbbs_roles ON gwbbs_controls.id = gwbbs_roles.title_id LEFT JOIN gwbbs_adms ON gwbbs_controls.id = gwbbs_adms.title_id"
    item = Gwbbs::Control
    # TODO: paginateを共通的に扱うスコープを用意し、モデル別にlimitのデフォルト値を管理する仕組みを用意する事。
    @items = item.joins(join).where(sql.where).order('sort_no, docslast_updated_at DESC').group('gwbbs_controls.id').
      paginate(page: params[:page]).limit(params[:limit])
  end

  def writeable_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      # 編集権限または、管理者権限が存在すること
      d.and "sql", "(gwbbs_roles.role_code = 'w' AND gwbbs_roles.group_code = '0' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '0')"
    }
    for group in Core.user.groups
      sql.or {|d|
        d.and :state, 'public'
        d.and :view_hide , 1
        # 編集権限または、管理者権限が存在すること
        d.and "sql", "(gwbbs_roles.role_code = 'w' AND gwbbs_roles.group_code = '#{group.code}' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '#{group.code}')"
      }

      unless group.parent.blank?
        sql.or {|d|
          d.and :state, 'public'
          d.and :view_hide , 1
          # 編集権限または、管理者権限が存在すること
          d.and "sql", "(gwbbs_roles.role_code = 'w' AND gwbbs_roles.group_code = '#{group.parent.code}' OR gwbbs_adms.group_id IS NOT NULL AND gwbbs_adms.group_code = '#{group.parent.code}')"
        }
      end
    end

    sql.or {|d|
      d.and :state, 'public'
      d.and :view_hide , 1
      # 編集権限または、管理者権限が存在すること
      d.and "sql", "(gwbbs_roles.role_code = 'w' AND gwbbs_roles.user_code = '#{Core.user.code}' OR gwbbs_adms.user_code = '#{Core.user.code}')"
    }
    join = "LEFT JOIN gwbbs_roles ON gwbbs_controls.id = gwbbs_roles.title_id LEFT JOIN gwbbs_adms ON gwbbs_controls.id = gwbbs_adms.title_id"
    item = Gwbbs::Control
    @items = item.joins(join).where(sql.where).order('sort_no, docslast_updated_at DESC').group('gwbbs_controls.id')
              .paginate(page: params[:page]).limit(params[:limit])
  end

protected

  def select_layout
    layout = "admin/template/portal"
    case params[:action].to_sym
    when :forward_select
      layout = "admin/template/forward_form"
    end
    layout
  end
end

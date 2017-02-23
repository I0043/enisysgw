# -*- encoding: utf-8 -*-
class Doclibrary::Admin::MenusController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Doclibrary::Model::DbnameAlias
  include Rumi::Doclibrary::Authorize

  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = I18n.t('activerecord.models.doclibrary/category')
    @piece_head_title = I18n.t("rumi.doclibrary.name")
    @side = "doclibrary"
  end

  def index
    if @gw_admin
      admin_index
    else
      readable_index
    end
  end

  def admin_index
    @items = Doclibrary::Control.where(state: 'public', view_hide: 1)
                                .order('sort_no, docslast_updated_at DESC, updated_at DESC')
                                .paginate_doclibrary(params)
  end

  # === 閲覧可能ファイル管理の取得メソッド
  #  本メソッドは、閲覧可能なファイル管理を取得するメソッドである。
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def readable_index
    # ログインユーザーの所属グループIDを取得（親グループを含む）
    user_group_parent_ids = Core.user.user_group_parent_ids

    # 管理権限のあるファイル管理のID取得
    admin_item = Doclibrary::Control.where(state: 'public', view_hide: 1)
    # TODO: 以下の複雑な条件を整理し、独自メソッドのandを使わないように修正する事。
    sql = Condition.new
    # 管理部門に関する条件
    sql.or do |d2|
      d2.and "doclibrary_adms.user_id", 0
      d2.and "doclibrary_adms.group_id", user_group_parent_ids
    end

    # 管理者に関する条件
    sql.or do |d2|
      d2.and "doclibrary_adms.user_id", Core.user.id
    end
    admin_control_ids = admin_item.where(sql.where)
             .joins("INNER JOIN doclibrary_adms ON doclibrary_controls.id = doclibrary_adms.title_id")
             .map(&:id)

    # 閲覧権限のあるファイル管理のID取得
    reader_item = Doclibrary::Control.where(state: 'public', view_hide: 1)
    # TODO: 以下の複雑な条件を整理し、独自メソッドのandを使わないように修正する事。
    sql = Condition.new
    # 閲覧権限「制限なし」に関する条件
    sql.or do |d2|
      d2.and "doclibrary_roles.role_code", "r"
      d2.and "doclibrary_roles.group_id", 0
    end

    # 閲覧部門に関する条件
    sql.or do |d2|
      d2.and "doclibrary_roles.role_code", "r"
      d2.and "doclibrary_roles.group_id", user_group_parent_ids
    end

    # 閲覧者に関する条件
    sql.or do |d2|
      d2.and "doclibrary_roles.role_code", "r"
      d2.and "doclibrary_roles.user_id", Core.user.id
    end
    reader_control_ids = reader_item.where(sql.where)
               .joins("INNER JOIN doclibrary_roles ON doclibrary_controls.id = doclibrary_roles.title_id")
               .map(&:id)

    # IDからファイル管理を取得
    readable_ids = (admin_control_ids + reader_control_ids).uniq.join(",")
    @items = []
    unless readable_ids.blank?
      @items = Doclibrary::Control.where("id IN (#{readable_ids})")
                                  .order("sort_no , docslast_updated_at DESC")
                                  .paginate_doclibrary(params)
    end
  end

end
